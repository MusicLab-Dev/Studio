/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Node list model
 */

#include "NodeListModel.hpp"

QHash<int, QByteArray> NodeListModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::NodeInstance), "nodeInstance" }
    };
}

QVariant NodeListModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 || index.row() < count(),
        throw std::range_error("NodeListModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    auto &elem = _models[index.row()];
    switch (static_cast<NodeListModel::Roles>(role)) {
    case Roles::NodeInstance:
        return QVariant::fromValue(NodeWrapper { elem });
    default:
        return QVariant();
    }
}

void NodeListModel::loadNode(NodeModel *node)
{
    beginResetModel();
    _models.clear();
    _models.append(node);
    endResetModel();
}

void NodeListModel::loadNodes(const QVector<NodeModel *> &models)
{
    beginResetModel();
    _models = models;
    endResetModel();
}