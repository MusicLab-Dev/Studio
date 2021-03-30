/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

#include "Models.hpp"

Scheduler::Scheduler(QObject *parent)
    : QObject(parent), Audio::AScheduler(), _device(DefaultDeviceDescription, &AScheduler::ConsumeAudioData, this)
{
    if (_Instance)
        throw std::runtime_error("Scheduler::Scheduler: An instance of the scheduler already exists");
    _Instance = this;
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
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
    /** TODO */
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