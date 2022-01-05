/**
 * @ Author: Cédric Lucchese
 * @ Description: Midi Controller Implementation
 */

#include <Vector>

#include "MidiController.hpp"

MidiController::MidiController()
{
    _portCount = _midiIn->getPortCount();
    for (int i = 0; i < _portCount; i++)
        _midiIn->openPort(i);
    connect(&_timer, SIGNAL(timeout()), this, SLOT(input()));
    _timer.start(0);
    _timer.setTimerType(Qt::PreciseTimer);
}

void MidiController::input() const noexcept
{
    std::vector<unsigned char> message;
    _midiIn->getMessage(&message);
    if (message.size() < 3)
        return;
    emit output(noteOn(message[0]), message[1], message[2]);
}

bool MidiController::noteOn(int message) const noexcept
{
    switch (message)
    {
    case 128:
        return false;
    case 144:
        return true;
    default:
        return false;        
    }
}

