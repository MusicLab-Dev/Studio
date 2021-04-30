/**
 * @ Author: Paul Creze
 * @ Description: Board
 */

#include "Board.hpp"


QHash<int, QByteArray> Board::roleNames(void) const
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Role::Type), "controlType" },
        { static_cast<int>(Role::Pos),  "controlPos" },
        { static_cast<int>(Role::Data), "controlData" }
    };
}

int Board::rowCount(const QModelIndex &parent) const
{
    (void)parent; // cast to clear "unused paramter" error
    return _controls.size();
}

QVariant Board::data(const QModelIndex &index, int role) const
{
    const auto &elem = _controls[index.row()];

    switch (static_cast<Role>(role)) {
    case Role::Type:
        return static_cast<int>(elem.type);
    case Role::Pos:
        return elem.pos;
    case Role::Data:
        return QVariant::fromValue(elem.data);
    default:
        throw std::logic_error("Board::data: Invalid role");
    }
}

[[nodiscard]] bool Board::setSize(const QSize &size)
{
    if (_size == size)
        return false;
    _size = size;
    emit sizeChanged();
    return true;
}
