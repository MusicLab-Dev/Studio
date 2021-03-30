/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

#include "Models.hpp"

Scheduler::Scheduler(QObject *parent)
    : QObject(parent), Audio::AScheduler(), _device(DefaultDeviceDescription, &AScheduler::ConsumeAudioData, this), _audioSpecs(Audio::AudioSpecs {
        _device.sampleRate(),
        static_cast<Audio::ChannelArrangement>(_device.channelArrangement()),
        static_cast<Audio::Format>(_device.format()),
        processBlockSize()
    })
{
    if (_Instance)
        throw std::runtime_error("Scheduler::Scheduler: An instance of the scheduler already exists");
    _Instance = this;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);

    connect(this, &Scheduler::audioThreadLocked, this, &Scheduler::onAudioThreadLocked, Qt::BlockingQueuedConnection);
    connect(this, &Scheduler::audioThreadLocked, this, &Scheduler::onAudioThreadReleased, Qt::QueuedConnection);
}

Scheduler::~Scheduler(void) noexcept
{
    _Instance = nullptr;
}

void Scheduler::setPlaybackMode(const PlaybackMode mode) noexcept
{
    Models::AddProtectedEvent(
        [this, mode] {
            Audio::AScheduler::setPlaybackMode(static_cast<Audio::PlaybackMode>(mode));
        },
        [this, mode = playbackMode()] {
            if (mode != playbackMode())
                emit playbackModeChanged();
        }
    );
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
            range.to = beat + Audio::AScheduler::processBeatSize();
            range.from = beat;
        },
        [this, currentBeat] {
            if (currentBeat != onTheFlyCurrentBeat())
                emit onTheFlyCurrentBeatChanged();
        }
    );
}

void Scheduler::onAudioBlockGenerated(void)
{
    // Currently in a worker thread, we must notify the main thread and block until events are processed
    emit onAudioThreadLocked();
}

void Scheduler::onAudioQueueBusy(void)
{
    /** TODO */
}

void Scheduler::play(void)
{
    if (setState(Audio::AScheduler::State::Play))
        _device.start();
}

void Scheduler::pause(void)
{
    if (setState(Audio::AScheduler::State::Pause))
        _device.stop();
}

void Scheduler::stop(void)
{
    if (!setState(Audio::AScheduler::State::Pause))
        _device.stop();
    switch (playbackMode()) {
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

void Scheduler::onAudioThreadLocked(void)
{
    qDebug() << "onAudioThreadLocked";
    AScheduler::dispatchApplyEvents();
}

void Scheduler::onAudioThreadReleased(void)
{
    qDebug() << "onAudioThreadReleased";
    AScheduler::dispatchNotifyEvents();
}