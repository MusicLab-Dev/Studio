/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

#include "Models.hpp"

Scheduler::Scheduler(Audio::ProjectPtr &&project, QObject *parent)
    :   QObject(parent),
        Audio::AScheduler(std::move(project)),
        _device(DefaultDeviceDescription, &Audio::AScheduler::ConsumeAudioData, this),
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

    setProcessParamByBlockSize(2048, _audioSpecs.sampleRate);
    _audioSpecs.processBlockSize = processBlockSize();
    // connect(&_device, &Device::sampleRateChanged, this, &Scheduler::refreshAudioSpecs);
    _timer.setTimerType(Qt::PreciseTimer);
    connect(&_timer, &QTimer::timeout, this, &Scheduler::onCatchingAudioThread);
}

Scheduler::~Scheduler(void) noexcept
{
    if (pauseImpl()) {
        __cxx_atomic_wait(reinterpret_cast<bool *>(&_blockGenerated), false, std::memory_order::memory_order_relaxed);
        onCatchingAudioThread();
        getCurrentGraph().wait();
    }

    _Instance = nullptr;
}

void Scheduler::setProductionCurrentBeat(const Beat beat)
{
    const auto currentBeat = productionCurrentBeat();

    if (currentBeat == beat)
        return;
    Models::AddProtectedEvent(
        [this, beat] {
            auto &range = Audio::AScheduler::currentBeatRange<Audio::PlaybackMode::Production>();
            range.to = beat + Audio::AScheduler::processBeatSize();
            range.from = beat;
        },
        [this, currentBeat] {
            if (currentBeat != productionCurrentBeat())
                emit productionCurrentBeatChanged();
        }
    );
}

void Scheduler::setLiveCurrentBeat(const Beat beat)
{
    const auto currentBeat = liveCurrentBeat();

    if (currentBeat == beat)
        return;
    Models::AddProtectedEvent(
        [this, beat] {
            auto &range = Audio::AScheduler::currentBeatRange<Audio::PlaybackMode::Live>();
            range.to = beat + Audio::AScheduler::processBeatSize();
            range.from = beat;
        },
        [this, currentBeat] {
            if (currentBeat != liveCurrentBeat())
                emit liveCurrentBeatChanged();
        }
    );
}

void Scheduler::setPartitionCurrentBeat(const Beat beat)
{
    const auto currentBeat = partitionCurrentBeat();

    if (currentBeat == beat)
        return;
    Models::AddProtectedEvent(
        [this, beat] {
            auto &range = Audio::AScheduler::currentBeatRange<Audio::PlaybackMode::Partition>();
            range.to = beat + Audio::AScheduler::processBeatSize();
            range.from = beat;
        },
        [this, currentBeat] {
            if (currentBeat != partitionCurrentBeat())
                emit partitionCurrentBeatChanged();
        }
    );
}

void Scheduler::setOnTheFlyCurrentBeat(const Beat beat)
{
    const auto currentBeat = onTheFlyCurrentBeat();

    if (currentBeat == beat)
        return;
    Models::AddProtectedEvent(
        [this, beat] {
            auto &range = Audio::AScheduler::currentBeatRange<Audio::PlaybackMode::OnTheFly>();
            range.to = beat + processBeatSize();
            range.from = beat;
        },
        [this, currentBeat] {
            if (currentBeat != onTheFlyCurrentBeat())
                emit onTheFlyCurrentBeatChanged();
        }
    );
}

bool Scheduler::onAudioBlockGenerated(void)
{
    _blockGenerated = true;
    while (_blockGenerated) {
        std::this_thread::yield();
    }
    return _exitGraph;
}

bool Scheduler::onAudioQueueBusy(void)
{
    _blockGenerated = true;
    while (_blockGenerated) {
        std::this_thread::yield();
    }
    return _exitGraph;
}

void Scheduler::play(const Scheduler::PlaybackMode mode)
{
    pauseImpl();
    Models::AddProtectedEvent(
        [this, mode] {
            setPlaybackMode(static_cast<Audio::PlaybackMode>(mode));
        },
        [this, mode = Audio::AScheduler::playbackMode()] {
            getCurrentGraph().wait();
            playImpl();
            if (mode != Audio::AScheduler::playbackMode())
                emit playbackModeChanged();
        }
    );
}

void Scheduler::playPartition(const Scheduler::PlaybackMode mode, NodeModel *node, const quint32 partition)
{
    const bool partitionNodeChanged = partitionNode() != node->audioNode();

    pauseImpl();
    Models::AddProtectedEvent(
        [this, mode, node, partition] {
            setPlaybackMode(static_cast<Audio::PlaybackMode>(mode));
            setPartitionNode(node->audioNode());
            setPartitionIndex(partition);
        },
        [this, mode = Audio::AScheduler::playbackMode(), partitionNodeChanged] {
            getCurrentGraph().wait();
            // if (partitionNodeChanged)
            invalidateCurrentGraph();
            playImpl();
            if (mode != Audio::AScheduler::playbackMode())
                emit playbackModeChanged();
        }
    );
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
    pauseImpl();
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

void Scheduler::replay(const Scheduler::PlaybackMode mode)
{
    pauseImpl();
    Models::AddProtectedEvent(
        [this, mode] {
            Audio::AScheduler::setPlaybackMode(static_cast<Audio::PlaybackMode>(mode));
            auto &range = Audio::AScheduler::getCurrentBeatRange();
            range.from = 0;
            range.to = Audio::AScheduler::processBeatSize();
        },
        [this, mode = Audio::AScheduler::playbackMode()] {
            getCurrentGraph().wait();
            playImpl();
            if (mode != Audio::AScheduler::playbackMode())
                emit playbackModeChanged();
            switch (mode) {
            case Audio::PlaybackMode::Production:
                emit productionCurrentBeatChanged();
                break;
            case Audio::PlaybackMode::Live:
                emit liveCurrentBeatChanged();
                break;
            case Audio::PlaybackMode::Partition:
                emit partitionCurrentBeatChanged();
                break;
            case Audio::PlaybackMode::OnTheFly:
                emit onTheFlyCurrentBeatChanged();
                break;
            }
        }
    );
}

void Scheduler::replayPartition(const Scheduler::PlaybackMode mode, NodeModel *node, const quint32 partition)
{
    const bool partitionNodeChanged = partitionNode() != node->audioNode();

    pauseImpl();
    Models::AddProtectedEvent(
        [this, mode, node, partition] {
            setPlaybackMode(static_cast<Audio::PlaybackMode>(mode));
            auto &range = Audio::AScheduler::getCurrentBeatRange();
            range.from = 0;
            range.to = Audio::AScheduler::processBeatSize();
            setPartitionNode(node->audioNode());
            setPartitionIndex(partition);
        },
        [this, mode = Audio::AScheduler::playbackMode(), partitionNodeChanged] {
            getCurrentGraph().wait();
            // if (partitionNodeChanged)
            invalidateCurrentGraph();
            playImpl();
            if (mode != Audio::AScheduler::playbackMode())
                emit playbackModeChanged();
            switch (mode) {
            case Audio::PlaybackMode::Production:
                emit productionCurrentBeatChanged();
                break;
            case Audio::PlaybackMode::Live:
                emit liveCurrentBeatChanged();
                break;
            case Audio::PlaybackMode::Partition:
                emit partitionCurrentBeatChanged();
                break;
            case Audio::PlaybackMode::OnTheFly:
                emit onTheFlyCurrentBeatChanged();
                break;
            }
        }
    );
}

bool Scheduler::playImpl(void)
{
    if (setState(Audio::AScheduler::State::Play)) {
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
    } else
        return false;
}

Beat Scheduler::getCurrentBeatOfMode(const Scheduler::PlaybackMode mode) const noexcept
{
    switch (mode) {
    case PlaybackMode::Production:
        return productionCurrentBeat();
    case PlaybackMode::Live:
        return liveCurrentBeat();
    case PlaybackMode::Partition:
        return partitionCurrentBeat();
    case PlaybackMode::OnTheFly:
        return onTheFlyCurrentBeat();
    default:
        return Beat();
    }
}

void Scheduler::onCatchingAudioThread(void)
{
    if (!_blockGenerated)
        return;
    AScheduler::dispatchApplyEvents();
    _exitGraph = state() == Scheduler::State::Pause;
    _blockGenerated = false;
    if (_exitGraph)
        _timer.stop();
    AScheduler::dispatchNotifyEvents();
    switch (playbackMode()) {
    case PlaybackMode::Production:
        emit productionCurrentBeatChanged();
        break;
    case PlaybackMode::Live:
        emit liveCurrentBeatChanged();
        break;
    case PlaybackMode::Partition:
        emit partitionCurrentBeatChanged();
        break;
    case PlaybackMode::OnTheFly:
        emit onTheFlyCurrentBeatChanged();
        break;
    }
}
