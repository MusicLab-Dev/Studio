/**
 * @ Author: Cédric Lucchese
 * @ Description: Node Model implementation
 */

#include <stdexcept>

#include <QDebug>
#include <QHash>
#include <QQmlEngine>
#include <QColor>

#include <Audio/PluginTable.hpp>

#include "Models.hpp"
#include "NodeModel.hpp"

static const QColor Colors[] = {
    QColor(0x31A8FF),
    QColor(0x00C5FF),
    QColor(0x00DCE7),
    QColor(0x00ECBA),
    QColor(0x9EF78C),
    QColor(0xFFD569),
    QColor(0xFFB377),
    QColor(0xFF978F),
    QColor(0xFF85A8),
    QColor(0xF382BB),
    QColor(0xDF83CE),
    QColor(0xC487DE),
    QColor(0xAC90EC),
    QColor(0x8E98F7),
    QColor(0x69A1FD)
};

constexpr std::size_t ColorCount = sizeof(Colors) / sizeof(Colors[0]);

static std::size_t CurrentColorIndex = 0u;

NodeModel::NodeModel(Audio::Node *node, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(node), _partitions(&node->partitions(), this), _controls(&node->controls(), this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _data->setColor(static_cast<std::uint32_t>(Colors[CurrentColorIndex].rgba()));
    if (++CurrentColorIndex >= ColorCount)
        CurrentColorIndex = 0u;
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

void NodeModel::setMuted(const bool muted)
{
    Models::AddProtectedEvent(
        [this, muted] {
            _data->setMuted(muted);
        },
        [this, muted = _data->muted()] {
            if (muted != _data->muted())
                emit mutedChanged();
        }
    );
}

void NodeModel::setName(const QString &name)
{
    Models::AddProtectedEvent(
        [this, name = Core::FlatString(name.toStdString())](void) mutable { _data->setName(std::move(name)); },
        [this, name = _data->name()] {
            if (name != _data->name())
                emit nameChanged();
        }
    );
}

void NodeModel::setColor(const QColor &color)
{
    Models::AddProtectedEvent(
        [this, color = static_cast<std::uint32_t>(color.rgba())] {
            _data->setColor(color);
        },
        [this, color = _data->color()] {
            if (color != _data->color())
                emit colorChanged();
        }
    );
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

    Models::AddProtectedEvent(
        [this, factory, plugin = std::move(plugin)](void) mutable {
            auto &backendChild = _data->children().push(std::make_unique<Audio::Node>(std::move(plugin)));
            backendChild->setName(Core::FlatString(factory->getName()));
            // backendChild->prepareCache(specs);
        },
        [this] {
            const auto idx = _children.size();
            beginInsertRows(QModelIndex(), idx, idx);
            _children.push(_data->children().back().get(), this);
            endInsertRows();
        }
    );
}

void NodeModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("NodeModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    Models::AddProtectedEvent(
        [this, idx] {
            _data->children().erase(_data->children().begin() + idx);
        },
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _children.erase(_children.begin() + idx);
            endRemoveRows();
        }
    );
}