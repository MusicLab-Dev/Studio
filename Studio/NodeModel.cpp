/**
 * @ Author: Cédric Lucchese
 * @ Description: Node Model implementation
 */

#include <stdexcept>

#include <QQmlEngine>

#include "NodeModel.hpp"

NodeModel::NodeModel(QObject *parent) noexcept
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> NodeModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { Roles::Node, "node" }
    };
}

QVariant NodeModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() < 0 || index.row() >= count(),
        throw std::range_error("InstancesModel::data: Given index is not in range"));
    const auto &child = (*_data)[index.row()];
    switch (role) {
    case Roles::Node:
        return child.get();
    default:
        return QVariant();
    }
}

bool NodeModel::setMuted(bool muted) noexcept
{
    if (_muted == muted)
        return false;
    _muted = muted;
    emit mutedChanged();
    return true;
}

bool NodeModel::setName(const QString &name) noexcept
{
    if (_name == name)
        return false;
    _name = name;
    emit nameChanged();
    return true;
}

bool NodeModel::setColor(const QColor &color) noexcept
{
    if (_color == color)
        return false;
    _color = color;
    emit colorChanged();
    return true;
}
