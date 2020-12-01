/**
 * @ Author: Cédric Lucchese
 * @ Description: Point gadget
 */

bool Point::setType(const CurveType type_) noexcept
{
    if (type == type_)
        return false;
    type = type_;
    return true;
}