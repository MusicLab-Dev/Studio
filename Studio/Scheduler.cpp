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

void Scheduler::setCurrentBeat(const Audio::Beat beat)
{
    if (currentBeat() == beat)
        return;
    Models::AddProtectedEvent(
        [this, beat] {
            auto range = Audio::AScheduler::currentBeatRange();
            range.to = beat + Audio::AScheduler::processBeatSize(); // Change to settings getter: processing length
            range.from = beat;
            Audio::AScheduler::setBeatRange(range);
        },
        [this] {
            emit currentBeatChanged();
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
    setCurrentBeat(0);
}