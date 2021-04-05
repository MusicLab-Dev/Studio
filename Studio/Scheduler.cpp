/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

#include "Models.hpp"

Scheduler::Scheduler(Audio::ProjectPtr &&project, QObject *parent)
    :   QObject(parent),
        Audio::AScheduler(std::move(project)), _device(DefaultDeviceDescription, &AScheduler::ConsumeAudioData, this),
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
            std::cout << "setProductionCurrentBeat " << beat << std::endl;
            auto &range = Audio::AScheduler::currentBeatRange<Audio::PlaybackMode::Production>();
            range.to = beat + Audio::AScheduler::processBeatSize();
            range.from = beat;
        },
        [this, currentBeat] {
            std::cout << "setProductionCurrentBeat2 " << currentBeat << std::endl;
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
    std::cout << "onAudioBlockGenerated wait" << std::endl;
    _blockGenerated = true;
    while (_blockGenerated)
        std::this_thread::yield();
    // __cxx_atomic_wait(reinterpret_cast<bool *>(&_blockGenerated), true, std::memory_order::memory_order_relaxed);
    std::cout << "onAudioBlockGenerated released" << std::endl;
}

void Scheduler::onAudioQueueBusy(void)
{
    std::cout << "onAudioQueueBusy wait" << std::endl;
    _blockGenerated = true;
    while (_blockGenerated)
        std::this_thread::yield();
    // __cxx_atomic_wait(reinterpret_cast<bool *>(&_blockGenerated), true, std::memory_order::memory_order_relaxed);
    std::cout << "onAudioQueueBusy released" << std::endl;
}

void Scheduler::play(void)
{
    if (setState(Audio::AScheduler::State::Play)) {
        _device.start();
        _timer.start();
    }
}

void Scheduler::pause(void)
{
    if (setState(Audio::AScheduler::State::Pause))
        _device.stop();
}

void Scheduler::stop(void)
{
    if (setState(Audio::AScheduler::State::Pause))
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

void Scheduler::onCatchingAudioThread(void)
{
    if (!_blockGenerated)
        return;
    std::cout << "Dispatch events" << std::endl;
    AScheduler::dispatchApplyEvents();
    std::cout << "Dispatch notify" << std::endl;
    AScheduler::dispatchNotifyEvents();
    _blockGenerated = false;
    // if (state() == Scheduler::State::Pause)
    //     _timer.stop();
}
