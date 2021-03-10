/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

#include "Scheduler.hpp"

Scheduler::Scheduler(QObject *parent)
    : QObject(parent), Audio::AScheduler()
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

void Scheduler::play(void)
{
    setState(Audio::AScheduler::State::Play);
}

void Scheduler::pause(void)
{
    setState(Audio::AScheduler::State::Pause);
}

void Scheduler::stop(void)
{
    setState(Audio::AScheduler::State::Pause);
    Audio::AScheduler::addEvent([this] {
        setCurrentBeat(0);
    });
}