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
    using Audio::Note::Note;
    using Audio::Note::operator=;
    using Audio::Note::operator==;
    using Audio::Note::operator!=;
    using Audio::Note::operator<;
    using Audio::Note::operator>;
    using Audio::Note::operator<=;
    using Audio::Note::operator>=;

    template<typename ...Args>
    Note(Args &&...args) noexcept : Audio::Note({ std::forward<Args>(args)... }) {}

public slots:
    void add(const Beat &beat)
    {
        range.from += beat;
        range.to += beat;
    }

    BeatRange getAdd(const Beat &beat)
    {
        return (BeatRange({range.from + beat, range.to + beat}));
    }

    BeatRange getSet(const Beat &from, const Beat &to)
    {
        return (BeatRange({range.from + from, range.to + to}));
    }
};
Q_DECLARE_METATYPE(Note)

struct NoteEvent : public Audio::NoteEvent
{
    Q_GADGET

    Q_PROPERTY(EventType type READ getType)
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

    using Audio::NoteEvent::NoteEvent;
    using Audio::NoteEvent::operator=;

    template<typename ...Args>
    NoteEvent(Args &&...args) noexcept : Audio::NoteEvent({ std::forward<Args>(args)... }) {}

    [[nodiscard]] EventType getType(void) const noexcept { return static_cast<EventType>(type); }
};
Q_DECLARE_METATYPE(NoteEvent)
