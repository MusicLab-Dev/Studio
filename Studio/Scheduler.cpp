/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

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
        _timer(this),
        _audioSpecs(Audio::AudioSpecs {
            _device.sampleRate(),
            static_cast<Audio::ChannelArrangement>(_device.channelArrangement()),
            static_cast<Audio::Format>(_device.format()),
            0
        }
    )
{
    if (_Instance)
        throw std::runtime_error("Scheduler::Scheduler: An instance of the scheduler already exists");
    _Instance = this;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);

    setProcessParamByBlockSize(static_cast<BlockSize>(parentApp()->settings()->getDefault("processBlockSize", 1024u).toUInt()), _audioSpecs.sampleRate);
    setAudioBlockSize(_device.blockSize());
    _audioSpecs.processBlockSize = processBlockSize();
    // connect(&_device, &Device::sampleRateChanged, this, &Scheduler::refreshAudioSpecs);
    _timer.setTimerType(Qt::PreciseTimer);
    connect(&_timer, &QTimer::timeout, this, &Scheduler::onCatchingAudioThread);
}

Scheduler::~Scheduler(void) noexcept
{
    stopAndWait();

    _Instance = nullptr;
}

Beat Scheduler::currentBeat(void) const noexcept
{
    switch (playbackMode()) {
    case PlaybackMode::Production:
        return productionCurrentBeat();
    case PlaybackMode::Live:
        return liveCurrentBeat();
    case PlaybackMode::Partition:
        return partitionCurrentBeat();
    case PlaybackMode::OnTheFly:
        return onTheFlyCurrentBeat();
    default:
        return 0u;
    }
}

void Scheduler::setCurrentBeat(const Beat beat)
{
    switch (playbackMode()) {
    case PlaybackMode::Production:
        return setProductionCurrentBeat(beat);
    case PlaybackMode::Live:
        return setLiveCurrentBeat(beat);
    case PlaybackMode::Partition:
        return setPartitionCurrentBeat(beat);
    case PlaybackMode::OnTheFly:
        return setOnTheFlyCurrentBeat(beat);
    }
}

void Scheduler::setProductionCurrentBeat(const Beat beat)
{
    const auto currentBeat = productionCurrentBeat();

    if (currentBeat == beat)
        return;
    addEvent(
        [this, beat] {
            auto &range = currentBeatRange<Audio::PlaybackMode::Production>();
            range.to = beat + processBeatSize();
            range.from = beat;
        }
    );
}

void Scheduler::setLiveCurrentBeat(const Beat beat)
{
    const auto currentBeat = liveCurrentBeat();

    if (currentBeat == beat)
        return;
    addEvent(
        [this, beat] {
            auto &range = currentBeatRange<Audio::PlaybackMode::Live>();
            range.to = beat + processBeatSize();
            range.from = beat;
        }
    );
}

void Scheduler::setPartitionCurrentBeat(const Beat beat)
{
    const auto currentBeat = partitionCurrentBeat();

    if (currentBeat == beat)
        return;
    addEvent(
        [this, beat] {
            auto &range = currentBeatRange<Audio::PlaybackMode::Partition>();
            range.to = beat + processBeatSize();
            range.from = beat;
        }
    );
}

void Scheduler::setOnTheFlyCurrentBeat(const Beat beat)
{
    const auto currentBeat = onTheFlyCurrentBeat();

    if (currentBeat == beat)
        return;
    addEvent(
        [this, beat] {
            auto &range = currentBeatRange<Audio::PlaybackMode::OnTheFly>();
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

    auto &range = Audio::AScheduler::getCurrentBeatRange();
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

    auto &range = Audio::AScheduler::getCurrentBeatRange();
    if (range.from != startingBeat) {
        range.from = startingBeat;
        range.to = startingBeat + processBeatSize();
    }

    if (graphChanged) // @todo: Only invalidate the current
        invalidateCurrentGraph();

    playImpl();
}

void Scheduler::pause(const Scheduler::PlaybackMode)
{
    pauseImpl();
    /** @todo Update the conditions */
    // if (playbackMode() == mode) {
    //     pauseImpl();
    // } else {
    //     qDebug() << "Scheduler: Mode" << mode << "is not playing right now";
    // }
}

void Scheduler::stop(const Scheduler::PlaybackMode mode)
{
    stopAndWait();
    switch (mode) {
    case PlaybackMode::Production:
        return setProductionCurrentBeat(0u);
    case PlaybackMode::Live:
        return setLiveCurrentBeat(0u);
    case PlaybackMode::Partition:
        return setPartitionCurrentBeat(0u);
    case PlaybackMode::OnTheFly:
        return setOnTheFlyCurrentBeat(0u);
    }
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
        _pausing = true;
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
    const bool wasPausing = _pausing;
    if (wasPausing || pauseImpl()) {
        if (!wasPausing) {
            std::atomic_wait_explicit(&_blockGenerated, false, std::memory_order::memory_order_relaxed);
            onCatchingAudioThread();
        }
        wait();
        setDirtyFlags();
        setProductionCurrentBeat(0u);
        setLiveCurrentBeat(0u);
        setPartitionCurrentBeat(0u);
        setOnTheFlyCurrentBeat(0u);
        disableLoopRange();
    }
}

void Scheduler::reloadDevice(const QString &name)
{
    stopAndWait();
    _device.setName(name);
}

void Scheduler::onCatchingAudioThread(void)
{
    if (!_blockGenerated)
        return;
    AScheduler::dispatchApplyEvents();
    _exitGraph = state() == Scheduler::State::Pause;

    // Check if we should stop on the fly graph
    if (playbackMode() == PlaybackMode::OnTheFly && _onTheFlyMissCount > OnTheFlyMissThreshold) {
        std::cout << "Missed" << std::endl;
        _onTheFlyMissCount = 0u;
        pauseImpl();
        _exitGraph = true;
    }

    _blockGenerated = false;
    std::atomic_notify_one(&_blockGenerated);
    _pausing = false;

    if (_exitGraph) {
        _timer.stop();
        graphExited();
    }
    AScheduler::dispatchNotifyEvents();

    if (!_busy) {
        if (_currentAnalysisTick >= _analysisTickRate) {
            _currentAnalysisTick = 0u;
            emit analysisCacheUpdated();
        } else
            ++_currentAnalysisTick;
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
    Audio::AScheduler::consumeAudioData(data, size);
}
