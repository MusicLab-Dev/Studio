/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Note
 */

#pragma once

#include <QObject>

#include <Audio/Note.hpp>

#include "Base.hpp"

struct Note : public Audio::Note
{
    Q_GADGET

    Q_PROPERTY(BeatRange range MEMBER range)
    Q_PROPERTY(Key key MEMBER key)
    Q_PROPERTY(Velocity velocity MEMBER velocity)
    Q_PROPERTY(Tuning tuning MEMBER tuning)

public:
    enum class EventType {
        On,
        Off,
        PolyPressure
    };
    Q_ENUM(EventType)

    using Audio::Note::Note;
    using Audio::Note::operator=;
};