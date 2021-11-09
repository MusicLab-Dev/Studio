/**
 * @ Author: Cédric Lucchese
 * @ Description: Main AudioAPI header
 */

#pragma once

#include <QObject>

#include "Point.hpp"
#include "ControlEvent.hpp"
#include "Note.hpp"
#include "PartitionInstance.hpp"
#include "VolumeCache.hpp"
#include "ControlDescriptor.hpp"

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
    BeatRange beatRange(const Beat from, const Beat to) const noexcept
        { return BeatRange(from, to); }

    /** @brief Create an audio note */
    Note note(const BeatRange &range, const Key key, const Velocity velocity, const Tuning tuning) const noexcept
        { return Note(range, key, velocity, tuning); }

    /** @brief Create an audio note event */
    NoteEvent noteEvent(const NoteEvent::EventType type, const Key key, const Velocity velocity, const Tuning tuning) const noexcept
        { return NoteEvent(static_cast<Audio::NoteEvent::EventType>(type), key, velocity, tuning); }

    /** @brief Create a control event */
    ControlEvent controlEvent(const ParamID paramID, const ParamValue value) const noexcept
        { return ControlEvent(paramID, value); }

    /** @brief Create an audio point */
    GPoint point(const Beat beat, const GPoint::CurveType curveType, const GPoint::CurveRate curveRate, const ParamValue paramValue) const noexcept
        { return GPoint(beat, static_cast<Audio::Point::CurveType>(curveType), curveRate, paramValue); }

    /** @brief Create a partition instance */
    PartitionInstance partitionInstance(const quint32 partitionIndex, const Beat offset, const BeatRange &range) const noexcept
        { return PartitionInstance(partitionIndex, offset, range); }

    /** @brief Create a volume cache */
    VolumeCache volumeCache(const DB peak, const DB rms) const noexcept
        { return VolumeCache(peak, rms); }


    /** @brief Convert a decibel volume into a ratio */
    DB decibelToRatio(const DB volume) const noexcept
        { return Audio::ConvertDecibelToRatio(volume); }


    /** @brief Extract a control descriptor */
    ControlDescriptor getControlDescriptor(PluginModel *plugin, const ParamID paramID) const noexcept;

private:
    /** @brief Construct the API */
    explicit AudioAPI(QObject *parent = nullptr) : QObject(parent) {}
};
