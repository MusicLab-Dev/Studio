/**
 * @ Author: Cédric Lucchese
 * @ Description: Main AudioAPI header
 */

#pragma once

#include <QObject>
#include <QVariant>

#include "Point.hpp"
#include "Note.hpp"

/** @brief AudioAPI class */
class AudioAPI : public QObject
{
    Q_OBJECT

    Q_PROPERTY(quint32 beatPrecision READ beatPrecision CONSTANT)
    Q_PROPERTY(quint16 velocityMax READ velocityMax CONSTANT)

public:
    /** @brief Instantiate the singleton */
    [[nodiscard]] static inline AudioAPI *Instantiate(QObject *parent = nullptr) { return new AudioAPI(parent); }

    /** @brief Destructor */
    ~AudioAPI(void) override = default;

    /** @brief Maximum velocity property */
    [[nodiscard]] Velocity velocityMax(void) const noexcept { return std::numeric_limits<Velocity>::max(); }

    /** @brief Beat precision property */
    [[nodiscard]] quint32 beatPrecision(void) const noexcept { return Audio::BeatPrecision; }

public slots:
    /** @brief Create an audio beat range */
    QVariant beatRange(const quint32 from, const quint32 to) const noexcept
        { return QVariant::fromValue(BeatRange(from, to)); }

    /** @brief Create an audio note */
    QVariant note(const BeatRange &range, const quint8 key, const quint16 velocity, const quint16 tuning) const noexcept
        { return QVariant::fromValue(Note(range, key, velocity, tuning)); }

    /** @brief Create an audio note */
    QVariant noteEvent(const NoteEvent::EventType type, const quint8 key, const quint16 velocity, const quint16 tuning) const noexcept
        { return QVariant::fromValue(NoteEvent(static_cast<Audio::NoteEvent::EventType>(type), key, velocity, tuning)); }

    /** @brief Create an audio point */
    QVariant point(const quint32 beat, const GPoint::CurveType curveType, const qint16 curveRate, const double paramValue) const noexcept
        { return QVariant::fromValue(GPoint(beat, static_cast<Audio::Point::CurveType>(curveType), curveRate, paramValue)); }

private:
    /** @brief Construct the API */
    explicit AudioAPI(QObject *parent = nullptr) : QObject(parent) {}
};
