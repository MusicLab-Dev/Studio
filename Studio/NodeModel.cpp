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
#include "ThemeManager.hpp"

// Current color index from color chain
static quint32 CurrentColorIndex = 0u;

NodeModel::NodeModel(Audio::Node *node, QObject *parent) noexcept
    :   QAbstractListModel(parent),
        _data(node),
        _partitions(&node->partitions(), this),
        _controls(&node->controls(), this),
        _plugin(node->plugin(), this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _data->setColor(ThemeManager::GetColorFromChain(CurrentColorIndex++).rgba());
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

NodeModel *NodeModel::addNodeImpl(const QString &pluginPath, const bool addPartition)
{
    const std::string path = pluginPath.toStdString();
    const auto factory = Audio::PluginTable::Get().find(path);
    if (!factory) {
        qCritical() << "NodeModel::add: Invalid plugin path " << pluginPath;
        return nullptr;
    }
    Audio::PluginPtr plugin = factory->instantiate();
    if (!plugin) {
        qCritical() << "NodeModel::add: Couldn't intantiate plugin " << pluginPath;
        return nullptr;
    }

    auto audioNode = std::make_unique<Audio::Node>(_data, std::move(plugin));

    audioNode->setName(Core::FlatString(factory->getName()));
    audioNode->prepareCache(Scheduler::Get()->audioSpecs());
    audioNode->partitions().push().setName("Partition 0");

    NodePtr node(audioNode.get(), this);
    auto nodePtr = node.get();

    const bool hasPaused = Scheduler::Get()->pauseImpl();

    if (!Models::AddProtectedEvent(
            [this, audioNode = std::move(audioNode)](void) mutable {
                _data->children().push(std::move(audioNode));
            },
            [this, node = std::move(node), hasPaused](void) mutable {
                const auto idx = _children.size();
                beginInsertRows(QModelIndex(), idx, idx);
                _children.push(std::move(node));
                endInsertRows();
                if (hasPaused) {
                    Scheduler::Get()->getCurrentGraph().wait();
                    Scheduler::Get()->invalidateCurrentGraph();
                    Scheduler::Get()->playImpl();
                } else
                    Scheduler::Get()->invalidateCurrentGraph();
            }
        ))
        return nullptr;
    return nodePtr;
}

bool NodeModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("NodeModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    const bool hasPaused = Scheduler::Get()->pauseImpl();
    return Models::AddProtectedEvent(
        [this, idx] {
            _data->children().erase(_data->children().begin() + idx);
        },
        [this, idx, hasPaused] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _children.erase(_children.begin() + idx);
            endRemoveRows();
            if (hasPaused) {
                Scheduler::Get()->getCurrentGraph().wait();
                Scheduler::Get()->invalidateCurrentGraph();
                Scheduler::Get()->playImpl();
            } else
                Scheduler::Get()->invalidateCurrentGraph();
        }
    );
}

bool NodeModel::isAParent(NodeModel *node) const noexcept
{
    auto *p = parentNode();

    while (p) {
        if (p == node)
            return true;
        p = p->parentNode();
    }
    return false;
}
