/**
 * @ Author: Cédric Lucchese
 * @ Description: Node Model implementation
 */

#include <stdexcept>

#include <QDebug>
#include <QHash>
#include <QQmlEngine>
#include <QAbstractListModel>
#include <QColor>

#include <Audio/PluginTable.hpp>

#include "NodeModel.hpp"

NodeModel::NodeModel(Audio::Node *node, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(node), _partitions(&node->partitions(), this), _controls(&node->controls(), this)
{
    //updateInternal();
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> NodeModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Node), "node" }
    };
}

QVariant NodeModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() < 0 || index.row() >= count(),
        throw std::range_error("InstancesModel::data: Given index is not in range"));
    switch (static_cast<NodeModel::Roles>(role)) {
    case Roles::Node:
        return get(index.row());
    default:
        return QVariant();
    }
}

const NodeModel *NodeModel::get(const int index) const
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("PartitionsModel::get: Given index is not in range"));
    return _children.at(index).get();
}

void NodeModel::add(const QString &pluginPath)
{
    std::string path = pluginPath.toStdString();
    auto index = static_cast<int>(_data->children().size());
    auto factory = Audio::PluginTable::Get().find(path);
    if (!factory) {
        qCritical() << "NodeModel::add: Invalid plugin path " << pluginPath;
        return;
    }
    auto plugin = factory->instantiate();
    if (!plugin) {
        qCritical() << "NodeModel::add: Couldn't intantiate plugin " << pluginPath;
        return;
    }
    auto &backendChild = _data->children().push(std::make_unique<Audio::Node>(std::move(plugin)));
    backendChild->setName(Core::FlatString(backendChild->name()));
    // backendChild->prepareCache(specs);
    beginInsertRows(QModelIndex(), index, index);
    _children.push(backendChild.get(), this);
    endInsertRows();
}

bool NodeModel::setMuted(bool muted) noexcept
{
    if (_data->muted() == muted)
        return false;
    _data->setMuted(muted);
    emit mutedChanged();
    return true;
}

bool NodeModel::setName(const QString &name) noexcept
{
    if (_data->name() == name.toStdString())
        return false;
    _data->setName(Core::FlatString(name.toStdString()));
    emit nameChanged();
    return true;
}

bool NodeModel::setColor(const QColor &color) noexcept
{
    if (!_data->setColor(static_cast<int>(color.rgba())))
        return false;
    emit colorChanged();
    return true;
}
