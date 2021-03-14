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
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> NodeModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::NodeInstance), "nodeInstance" },
    };
}

QVariant NodeModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 || index.row() < count(),
        throw std::range_error("NodeModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    const auto &child = _children[index.row()];
    switch (static_cast<NodeModel::Roles>(role)) {
    case Roles::NodeInstance:
        return QVariant::fromValue(NodeWrapper { const_cast<NodeModel *>(child.get()) });
    default:
        return QVariant();
    }
}

const NodeModel *NodeModel::get(const int idx) const
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("NodeModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return _children.at(idx).get();
}

void NodeModel::add(const QString &pluginPath)
{
    std::string path = pluginPath.toStdString();
    auto idx = static_cast<int>(_data->children().size());
    auto factory = Audio::PluginTable::Get().find(path);
    if (!factory) {
        qCritical() << "NodeModel::add: Invalid plugin path " << pluginPath;
        return;
    }
    Audio::PluginPtr plugin = factory->instantiate();
    if (!plugin) {
        qCritical() << "NodeModel::add: Couldn't intantiate plugin " << pluginPath;
        return;
    }

    // Scheduler::Get()->addEvent(
    // [this, plugin = std::move(plugin)] {
    // },
    // [this] {
    // });
    auto &backendChild = _data->children().push(std::make_unique<Audio::Node>(std::move(plugin)));
    backendChild->setName(Core::FlatString(factory->getName()));
    // backendChild->prepareCache(specs);
    beginInsertRows(QModelIndex(), idx, idx);
    _children.push(backendChild.get(), this);
    endInsertRows();
    emit countChanged();
}

void NodeModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("NodeModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    beginRemoveRows(QModelIndex(), idx, idx);
    _children.erase(_children.begin() + idx);
    _data->children().erase(_data->children().begin());
    endRemoveRows();
    emit countChanged();
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
