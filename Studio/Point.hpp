/**
 * @ Author: Cédric Lucchese
 * @ Description: Point gadget
 */

#pragma once

#include <QObject>

#include <Audio/Point.hpp>

#include "Base.hpp"

struct GPoint : public Audio::Point
{
    Q_GADGET

    Q_PROPERTY(Beat beat MEMBER beat)
    Q_PROPERTY(CurveType curveType READ getType WRITE setType)
    Q_PROPERTY(GPoint::CurveRate curveRate MEMBER curveRate)
    Q_PROPERTY(ParamValue value MEMBER value)

public:
    /** @brief Describe the interpolation type between points */
    enum class CurveType : std::uint8_t {
        Linear,
        Fast,
        Slow
    };
    Q_ENUM(CurveType)

    using CurveRate = Audio::Point::CurveRate;

    using Audio::Point::Point;
    using Audio::Point::operator=;

    template<typename ...Args>
    GPoint(Args &&...args) noexcept : Audio::Point({ std::forward<Args>(args)... }) {}

    /** @brief Get / Set the internal curve type */
    [[nodiscard]] CurveType getType(void) const noexcept { return static_cast<GPoint::CurveType>(type); }
    void setType(const CurveType type_) noexcept { type = static_cast<Audio::Point::CurveType>(type_); }
};

Q_DECLARE_METATYPE(GPoint)
