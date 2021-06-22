/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Node list model
 */

#include "NodeListModel.hpp"

QHash<int, QByteArray> roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Instance), "nodeInstance" }
    };
}

QVariant NodeListModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 || index.row() < count(),
        throw std::range_error("NodeListModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    const auto &elem = _models[index.row()];
    switch (static_cast<NodeModel::Roles>(role)) {
    case Roles::NodeInstance:
        return QVariant::fromValue(NodeWrapper { const_cast<NodeModel *>(elem.get()) });
    default:
        return QVariant();
    }
}
