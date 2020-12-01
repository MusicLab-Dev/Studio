/**
 * @ Author: Cédric Lucchese
 * @ Description: Point gadget
 */

#pragma once

#include <QObject>

#include <Audio/Automation.hpp> // Todo: replace with <Audio/Point>

struct Point : public Audio::Point
{
    Q_GADGET

    Q_PROPERTY(Audio::Beat beat MEMBER beat)
    Q_PROPERTY(CurveType type READ getType WRITE setType)
    Q_PROPERTY(std::int16_t curveRate MEMBER curveRate)

public:
    /** @brief Describe the interpolation type between points */
    enum class CurveType : std::uint8_t {
        Linear, Fast, Slow
    };
    Q_ENUMS(CurveType)

    /** @brief Get / Set the internal curve type */
    [[nodiscard]] CurveType getType(void) const noexcept { return static_cast<Point::CurveType>(type); }
    bool setType(const CurveType type_) noexcept;

};

Q_DECLARE_METATYPE(Point)

#include "Point.ipp"