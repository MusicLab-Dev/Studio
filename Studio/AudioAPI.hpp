/**
 * @ Author: Cédric Lucchese
 * @ Description: Main AudioAPI header
 */

#pragma once

#include <QObject>
#include <QVariant>

#include "Point.hpp"
#include "Control.hpp"
#include "Note.hpp"

/** @brief AudioAPI class */
class AudioAPI : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Beat beatPrecision READ beatPrecision CONSTANT)
    Q_PROPERTY(Velocity velocityMax READ velocityMax CONSTANT)
    Q_PROPERTY(Tuning tuningMax READ tuningMax CONSTANT)

public:
    /** @brief Instantiate the singleton */
    [[nodiscard]] static inline AudioAPI *Instantiate(QObject *parent = nullptr) { return new AudioAPI(parent); }

    /** @brief Destructor */
    ~AudioAPI(void) override = default;

    /** @brief Maximum velocity property */
    [[nodiscard]] Velocity velocityMax(void) const noexcept { return std::numeric_limits<Velocity>::max(); }

    /** @brief Maximum tuning property */
    [[nodiscard]] Tuning tuningMax(void) const noexcept { return std::numeric_limits<Tuning>::max(); }

    /** @brief Beat precision property */
    [[nodiscard]] Beat beatPrecision(void) const noexcept { return Audio::BeatPrecision; }

public slots:
    /** @brief Create an audio beat range */
    QVariant beatRange(const Beat from, const Beat to) const noexcept
        { return QVariant::fromValue(BeatRange(from, to)); }

    /** @brief Create an audio note */
    QVariant note(const BeatRange &range, const Key key, const Velocity velocity, const Tuning tuning) const noexcept
        { return QVariant::fromValue(Note(range, key, velocity, tuning)); }

    /** @brief Create an audio note event */
    QVariant noteEvent(const NoteEvent::EventType type, const Key key, const Velocity velocity, const Tuning tuning) const noexcept
        { return QVariant::fromValue(NoteEvent(static_cast<Audio::NoteEvent::EventType>(type), key, velocity, tuning)); }

    /** @brief Create a control event */
    QVariant controlEvent(const ParamID paramID, const ParamValue value) const noexcept
        { return QVariant::fromValue(ControlEvent(paramID, value)); }

    /** @brief Create an audio point */
    QVariant point(const Beat beat, const GPoint::CurveType curveType, const GPoint::CurveRate curveRate, const ParamValue paramValue) const noexcept
        { return QVariant::fromValue(GPoint(beat, static_cast<Audio::Point::CurveType>(curveType), curveRate, paramValue)); }

private:
    /** @brief Construct the API */
    explicit AudioAPI(QObject *parent = nullptr) : QObject(parent) {}
};
