/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

#include "Scheduler.hpp"

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

bool Scheduler::setCurrentBeat(const Audio::Beat beat) noexcept
{
    if (currentBeat() == beat)
        return false;
    auto range = Audio::AScheduler::currentBeatRange();
    range.to = beat + 2048; // Change to settings getter: processing length
    range.from = beat;
    Audio::AScheduler::setBeatRange(range);
    emit currentBeatChanged();
    return true;
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
    Audio::AScheduler::addEvent([this] {
        setCurrentBeat(0);
    });
}