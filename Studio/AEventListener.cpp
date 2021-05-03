/**
 * @ Author: Cédric Lucchese
 * @ Description: Abstract event listener cpp
 */

#include "EventDispatcher.hpp"
#include "AEventListener.hpp"

QHash<int, QByteArray> AEventListener::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(AEventListener::Roles::Input), "roleInput" }
    };
}

QVariant AEventListener::data(const QModelIndex &index, int role) const
{
    (void)index;
    /*coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("AEventListener::get: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    */
    switch (static_cast<AEventListener::Roles>(role)) {
        case AEventListener::Roles::Input:
            return QVariant();
        default:
            return QVariant();
    }
}
