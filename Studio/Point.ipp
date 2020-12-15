/**
 * @ Author: Cédric Lucchese
 * @ Description: Point gadget
 */

inline bool GPoint::setType(const CurveType type_) noexcept
{
    const auto audioCurve = static_cast<Audio::Point::CurveType>(type_);

    if (type == audioCurve)
        return false;
    type = audioCurve;
    return true;
}