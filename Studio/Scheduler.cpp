/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

#include <Audio/PluginTable.hpp>

#include "Application.hpp"
#include "Models.hpp"

Audio::Device::LogicalDescriptor Scheduler::getDeviceDescriptor(void)
{
    auto p = parentApp();
    if (!p)
        return DefaultDeviceDescription;
    else {
        auto settings = p->settings();
        return Audio::Device::LogicalDescriptor {
            /*.name =               */ settings->getDefault("outputDevice", Audio::Device::DefaultDeviceName).toString().toStdString(),
            /*.blockSize =          */ static_cast<BlockSize>(settings->getDefault("blockSize", 1024u).toUInt()),
            /*.sampleRate =         */ static_cast<SampleRate>(settings->getDefault("sampleRate", 44100).toUInt()),
            /*.isInput =            */ false,
            /*.format =             */ Audio::Format::Floating32,
            /*.midiChannels =       */ 2u,
            /*.channelArrangement = */ Audio::ChannelArrangement::Mono
        };
    }
}

Scheduler::Scheduler(Audio::ProjectPtr &&project, QObject *parent)
    :   QObject(parent),
        Audio::AScheduler(std::move(project)),
        _device(getDeviceDescriptor(), [this](std::uint8_t *data, const std::size_t size) { consumeAudioData(data, size); }, this),
        _timer(this)
{
    // Setup scheduler instance
    if (_Instance)
        throw std::runtime_error("Scheduler::Scheduler: An instance of the scheduler already exists");
    _Instance = this;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);

    // Setup process params
    const std::uint32_t cachedAudioFrames = parentApp()->settings()->getDefault("cachedAudioFrames", 3u).toUInt();
    setProcessParams(_device.blockSize(), _device.sampleRate(), cachedAudioFrames);
    _audioSpecs = Audio::AudioSpecs {
        _device.sampleRate(),
        static_cast<Audio::ChannelArrangement>(_device.channelArrangement()),
        static_cast<Audio::Format>(_device.format()),
        processBlockSize()
    };

    // Setup tick timer
    _timer.setTimerType(Qt::PreciseTimer);
    connect(&_timer, &QTimer::timeout, this, &Scheduler::onCatchingAudioThread);
}

Scheduler::~Scheduler(void) noexcept
{
    stopAndWait();

    _Instance = nullptr;
}

void Scheduler::setCurrentBeat(const Beat beat)
{
    const auto curr = currentBeat();

    if (curr == beat)
        return;
    addEvent(
        [this, beat] {
            auto &range = currentBeatRange();
            range.to = beat + processBeatSize();
            range.from = beat;
        }
    );
}

void Scheduler::setBPM(const BPM value) noexcept
{
    if (bpm() == value)
        return;
    addEvent(
        [this, value] {
            Audio::AScheduler::setBPM(value);
        },
        [this] {
            emit bpmChanged();
        }
    );
}

void Scheduler::setAnalysisTickRate(const quint32 tickRate) noexcept
{
    if (_analysisTickRate == tickRate)
        return;
    _analysisTickRate = tickRate;
    emit analysisTickRateChanged();
}

void Scheduler::play(const Scheduler::PlaybackMode mode, const Beat startingBeat, const BeatRange &loopRange)
{
    stopAndWait();

    if (mode != Scheduler::playbackMode()) {
        setPlaybackMode(static_cast<Audio::PlaybackMode>(mode));
        emit playbackModeChanged();
    }

    if (loopRange.from != loopRange.to)
        setLoopRange(loopRange);
    else
        disableLoopRange();

    auto &range = currentBeatRange();
    if (range.from != startingBeat) {
        range.to = startingBeat + processBeatSize();
        range.from = startingBeat;
    }

    playImpl();
}

void Scheduler::playPartition(const Scheduler::PlaybackMode mode, NodeModel *node, const quint32 partition, const Beat startingBeat, const BeatRange &loopRange)
{
    const bool graphChanged = partitionNode() != node->audioNode();
    // const bool partitionChanged = graphChanged || partitionIndex() != partition;

    stopAndWait();

    if (mode != Scheduler::playbackMode()) {
        setPlaybackMode(static_cast<Audio::PlaybackMode>(mode));
        emit playbackModeChanged();
    }
    setPartitionNode(node->audioNode());
    setPartitionIndex(partition);

    if (loopRange.from != loopRange.to)
        setLoopRange(loopRange);
    else
        disableLoopRange();

    auto &range = currentBeatRange();
    if (range.from != startingBeat) {
        range.from = startingBeat;
        range.to = startingBeat + processBeatSize();
    }

    if (graphChanged) // @todo: Only invalidate the current
        invalidateCurrentGraph();

    playImpl();
}

void Scheduler::pause(void)
{
    pauseImpl();
}

void Scheduler::stop(void)
{
    stopAndWait();
    setCurrentBeat(0u);
}

bool Scheduler::playImpl(void)
{
    if (setState(Audio::AScheduler::State::Play)) {
        _onTheFlyMissCount = 0u;
        _isOnTheFlyMode = playbackMode() == PlaybackMode::OnTheFly;
        _device.start();
        _timer.start();
        emit runningChanged();
        return true;
    } else
        return false;
}

bool Scheduler::pauseImpl(void)
{
    if (setState(Audio::AScheduler::State::Pause)) {
        _device.stop();
        emit runningChanged();
        return true;
    } else {
        return false;
    }
}

void Scheduler::onNodeDeleted(NodeModel *targetNode)
{
    if (partitionNode() == targetNode->audioNode()) {
        if (playbackMode() == PlaybackMode::Partition || playbackMode() == PlaybackMode::OnTheFly) {
            stopAndWait();
            setPlaybackMode(Audio::PlaybackMode::Production);
            emit playbackModeChanged();
        }
        addEvent([this] {
            setPartitionNode(nullptr);
            setPartitionIndex(0);
        });
    }
}

void Scheduler::onNodePartitionDeleted(NodeModel *targetNode, const quint32 partition)
{
    if (partitionNode() == targetNode->audioNode() && partition == partitionIndex()) {
        if (playbackMode() == PlaybackMode::Partition || playbackMode() == PlaybackMode::OnTheFly) {
            stopAndWait();
            setPlaybackMode(Audio::PlaybackMode::Production);
            emit playbackModeChanged();
        }
        addEvent([this] {
            setPartitionNode(nullptr);
            setPartitionIndex(0);
        });
    }
}

void Scheduler::setLoopRange(const BeatRange range)
{
    addEvent([this, range] {
        setIsLooping(true);
        setLoopBeatRange(range);
    });
}

void Scheduler::disableLoopRange(void)
{
    addEvent([this] {
        setIsLooping(false);
    });
}

void Scheduler::stopAndWait(void)
{
    if (pauseImpl()) {
        std::atomic_wait_explicit(&_blockGenerated, false, std::memory_order::memory_order_relaxed);
        onCatchingAudioThread();
        wait();
        invalidateCurrentGraph<true>();
        setCurrentBeat(0u);
        disableLoopRange();
    }
}

void Scheduler::changeDevice(const QString &name)
{
    stopAndWait();
    _device.setName(name);
}

void Scheduler::reloadAudioSpecs(void)
{
    stopAndWait();
    _device.setLogicalDescriptor(getDeviceDescriptor());
    const std::uint32_t cachedAudioFrames = parentApp()->settings()->getDefault("cachedAudioFrames", 3u).toUInt();
    setProcessParams(_device.blockSize(), _device.sampleRate(), cachedAudioFrames);
    _audioSpecs = Audio::AudioSpecs {
        _device.sampleRate(),
        static_cast<Audio::ChannelArrangement>(_device.channelArrangement()),
        static_cast<Audio::Format>(_device.format()),
        processBlockSize()
    };
    Audio::PluginTable::Get().updateAudioSpecs(_audioSpecs);
    prepareCache(_audioSpecs);
}

bool Scheduler::onAudioBlockGenerated(void)
{
    _busy = false;
    _blockGenerated = true;
    std::atomic_notify_one(&_blockGenerated);
    while (_blockGenerated) {
        std::this_thread::yield();
    }
    return _exitGraph;
}

bool Scheduler::onAudioQueueBusy(void)
{
    _busy = true;
    _blockGenerated = true;
    std::atomic_notify_one(&_blockGenerated);
    while (_blockGenerated) {
        std::this_thread::yield();
    }
    return _exitGraph;
}

void Scheduler::onCatchingAudioThread(void)
{
    if (!_blockGenerated)
        return;
    const bool busy = _busy;
    AScheduler::dispatchApplyEvents();
    _exitGraph = state() == Scheduler::State::Pause;

    // Check if we should stop on the fly graph
    if (!busy && playbackMode() == PlaybackMode::OnTheFly && _onTheFlyMissCount > OnTheFlyMissThreshold) {
        std::cout << "Missed" << std::endl;
        _onTheFlyMissCount = 0u;
        pauseImpl();
        _exitGraph = true;
    }

    _blockGenerated = false;
    std::atomic_notify_one(&_blockGenerated);

    if (_exitGraph) {
        _timer.stop();
        graphExited();
    }
    AScheduler::dispatchNotifyEvents();

    emit currentBeatChanged();

    if (!busy) {
        if (_currentAnalysisTick >= _analysisTickRate) {
            _currentAnalysisTick = 0u;
            emit analysisCacheUpdated();
        } else {
            ++_currentAnalysisTick;
        }
    }
}

void Scheduler::consumeAudioData(std::uint8_t *data, const std::size_t size) noexcept
{
    if (_isOnTheFlyMode) {
        if (std::all_of(data, data + size, [](const auto x) { return x == 0; }))
            ++_onTheFlyMissCount;
        else
            _onTheFlyMissCount = 0u;
    }
    if (!Audio::AScheduler::consumeAudioData(data, size))
        qDebug() << "Audio callback miss";
}
