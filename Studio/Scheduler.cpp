/**
 * @ Author: Cédric Lucchese
 * @ Description: Scheduler implementation
 */

#include <QQmlEngine>

#include "Scheduler.hpp"

Scheduler::Scheduler(Audio::Scheduler *scheduler, QObject *parent) noexcept
    : QObject(parent), _data(scheduler)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

bool Scheduler::setCurrentBeat(const Audio::Beat &beat) noexcept
{
    if (currentBeat() == beat)
        return false;
    _data->setCurrentBeat(beat);
    emit currentBeatChanged();
    return true;
}

void Scheduler::onAudioBlockGenerated(void) override final
{
    /** TODO */
}

void Scheduler::play(void)
{
    /** TODO */
}

void Scheduler::pause(void)
{
    /** TODO */
}

void Scheduler::stop(void)
{
    /** TODO */
}