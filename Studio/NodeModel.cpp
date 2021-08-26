/**
 * @ Author: Cédric Lucchese
 * @ Description: Node Model implementation
 */

#include <stdexcept>

#include <QDebug>
#include <QHash>
#include <QQmlEngine>
#include <QColor>
#include <QFileInfo>

#include <Audio/PluginTable.hpp>

#include "Application.hpp"
#include "Models.hpp"
#include "NodeModel.hpp"
#include "ThemeManager.hpp"

// Current color index from color chain
static quint32 CurrentColorIndex = 0u;

NodeModel::NodeModel(Audio::Node *node, QObject *parent) noexcept
    :   QAbstractListModel(parent),
        _data(node),
        _partitions(&node->partitions(), this),
        _automations(&node->automations(), this),
        _plugin(node->plugin(), this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _data->setColor(ThemeManager::GetColorFromChain(CurrentColorIndex++).rgba());
}

NodeModel::~NodeModel(void) noexcept
{
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
        [this, name = Core::FlatString(name.toStdString())](void) mutable {
            _data->setName(std::move(name));
        },
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

VolumeCache NodeModel::getVolumeCache(void) const noexcept
{
    if (_data && _data->cache())
        return VolumeCache(_data->cache().volumeCache());
    else
        return VolumeCache{};
}

void NodeModel::processLatestInstanceChange(const Beat oldInstance, const Beat newInstance)
{
    if (_latestInstance < newInstance) {
        const auto oldLatest = _latestInstance;
        _latestInstance = newInstance;
        emit latestInstanceChanged();
        if (const auto p = parentNode(); p)
            p->processLatestInstanceChange(oldLatest, _latestInstance);
    } else if (_latestInstance == oldInstance) {
        Beat max = 0;
        for (const auto &child : _children) {
            if (child->latestInstance() > max)
                max = child->latestInstance();
        }
        _latestInstance = max;
        emit latestInstanceChanged();
        if (const auto p = parentNode(); p)
            p->processLatestInstanceChange(oldInstance, _latestInstance);
    }
}

const NodeModel *NodeModel::get(const int idx) const
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("NodeModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return _children.at(idx).get();
}

std::unique_ptr<Audio::Node> NodeModel::prepareNode(const QString &pluginPath, const bool addPartition, const QStringList &paths)
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

    if (paths.empty())
        audioNode->setName(Core::FlatString(factory->getName()));
    else {
        QFileInfo fi(paths[0]);
        audioNode->setName(Core::FlatString(fi.baseName().toStdString()));
    }
    audioNode->prepareCache(Scheduler::Get()->audioSpecs());

    if (addPartition)
        audioNode->partitions().push();

    return audioNode;
}

NodeModel *NodeModel::addNodeImpl(const QString &pluginPath, const bool addPartition, const QStringList &paths)
{
    auto audioNode = prepareNode(pluginPath, addPartition, paths);
    if (!audioNode)
        return nullptr;

    NodePtr node(audioNode.get(), this);
    if (addPartition)
        node->partitions()->get(0)->setName("Partition 0");
    auto nodePtr = node.get();
    const bool hasPaused = Scheduler::Get()->pauseImpl();

    if (!paths.isEmpty())
        nodePtr->loadExternalInputs(paths);

    if (!Models::AddProtectedEvent(
            [this, audioNode = std::move(audioNode)](void) mutable {
                _data->children().push(std::move(audioNode));
            },
            [this, node = std::move(node), hasPaused](void) mutable {
                const auto idx = static_cast<int>(_children.size());
                beginInsertRows(QModelIndex(), idx, idx);
                _children.push(std::move(node));
                endInsertRows();
                if (hasPaused) {
                    Scheduler::Get()->graph().wait();
                    Scheduler::Get()->invalidateCurrentGraph();
                    Scheduler::Get()->playImpl();
                } else
                    Scheduler::Get()->invalidateCurrentGraph();
                processGraphChange();
            }
        ))
        return nullptr;
    return nodePtr;
}

NodeModel *NodeModel::addParentNodeImpl(const QString &pluginPath, const bool addPartition, const QStringList &paths)
{
    auto parent = parentNode();
    if (!parent)
        return nullptr;

    auto audioNode = prepareNode(pluginPath, addPartition, paths);
    if (!audioNode)
        return nullptr;

    NodePtr node(audioNode.get(), parent);
    auto nodePtr = node.get();
    const bool hasPaused = Scheduler::Get()->pauseImpl();

    if (!paths.isEmpty())
        nodePtr->loadExternalInputs(paths);

    if (!Models::AddProtectedEvent(
            [this, audioNode = std::move(audioNode)](void) mutable {
                auto parent = _data->parent();
                auto &self = *parent->children().find([this](const auto &p) { return p.get() == _data; });
                self.swap(audioNode);
                self->setParent(parent);
                audioNode->setParent(self.get());
                self->children().push(std::move(audioNode));
            },
            [this, node = std::move(node), hasPaused](void) mutable {
                auto parent = parentNode();
                setParent(node.get());
                int i = -1;
                auto &self = *parent->children().find([this, &i](const auto &p) { ++i; return p.get() == this; });
                self.swap(node);
                self->children().push(std::move(node));
                parent->dataChanged(parent->index(i), parent->index(i), { static_cast<int>(Roles::NodeInstance) });
                if (hasPaused) {
                    Scheduler::Get()->graph().wait();
                    Scheduler::Get()->invalidateCurrentGraph();
                    Scheduler::Get()->playImpl();
                } else
                    Scheduler::Get()->invalidateCurrentGraph();
                processGraphChange();
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
            auto scheduler = Scheduler::Get();
            beginRemoveRows(QModelIndex(), idx, idx);
            _children.erase(_children.begin() + idx);
            endRemoveRows();
            if (hasPaused) {
                scheduler->graph().wait();
                scheduler->invalidateCurrentGraph();
                scheduler->playImpl();
            } else
                scheduler->invalidateCurrentGraph();
            processGraphChange();
        }
    );
}

bool NodeModel::moveToChildren(NodeModel *target)
{
    const auto targetParent = target->parentNode();

    if (!targetParent) {
        qDebug() << "NodeModel: Cannot move a children that has no parent";
        return false;
    }

    const auto targetIndex = targetParent->getChildIndex(target);

    if (isAParent(target)) {
        qDebug() << "NodeModel: Cannot move a parent node to children";
        return false;
    }

    const bool hasPaused = Scheduler::Get()->pauseImpl();

    return Models::AddProtectedEvent(
        [this, target, targetIndex, hasPaused] {
            auto parentNode = target->parentNode();
            auto audioParent = parentNode->audioNode();
            auto audioPtr = std::move(audioParent->children().at(targetIndex));
            auto ptr = std::move(parentNode->_children.at(targetIndex));

            // Remove target node
            parentNode->beginRemoveRows(QModelIndex(), targetIndex, targetIndex);
            audioParent->children().erase(audioParent->children().begin() + targetIndex);
            parentNode->_children.erase(parentNode->_children.begin() + targetIndex);
            parentNode->endRemoveRows();

            audioPtr->setParent(audioParent);
            target->setParent(this);

            // Insert target into children
            beginInsertRows(QModelIndex(), count(), count());
            audioNode()->children().push(std::move(audioPtr));
            _children.push(std::move(ptr));
            endInsertRows();
        },
        [this, hasPaused] {
            if (hasPaused) {
                Scheduler::Get()->graph().wait();
                Scheduler::Get()->invalidateCurrentGraph();
                Scheduler::Get()->playImpl();
            } else
                Scheduler::Get()->invalidateCurrentGraph();
            processGraphChange();
        }
    );
}

bool NodeModel::moveToParent(NodeModel *target)
{
    if (parentNode() == nullptr) {
        qDebug() << "NodeModel: Cannot swap parent of a node that has no parent";
        return false;
    }

    const auto targetParent = target->parentNode();

    if (!targetParent) {
        qDebug() << "NodeModel: Cannot move a children that has no parent";
        return false;
    }

    const auto targetIndex = targetParent->getChildIndex(target);
    const bool hasPaused = Scheduler::Get()->pauseImpl();

    return Models::AddProtectedEvent(
        [this, target, targetIndex, hasPaused] {
            const auto targetParent = target->parentNode();
            auto audioPtr = std::move(targetParent->audioNode()->children().at(static_cast<std::uint32_t>(targetIndex)));
            auto ptr = std::move(targetParent->_children.at(targetIndex));

            // Remove target node
            targetParent->beginRemoveRows(QModelIndex(), targetIndex, targetIndex);
            targetParent->audioNode()->children().erase(targetParent->audioNode()->children().begin() + targetIndex);
            targetParent->_children.erase(targetParent->_children.begin() + targetIndex);
            targetParent->endRemoveRows();

            const auto selfParent = this->parentNode();
            const auto selfIndex = selfParent->getChildIndex(this);
            auto selfAudioPtr = std::move(selfParent->audioNode()->children().at(static_cast<std::uint32_t>(selfIndex)));
            auto selfPtr = std::move(selfParent->_children.at(selfIndex));

            // Remove this from self parent
            selfParent->beginRemoveRows(QModelIndex(), selfParent->count() - 1, selfParent->count() - 1);
            selfParent->audioNode()->children().erase(selfParent->audioNode()->children().begin() + selfIndex);
            selfParent->_children.erase(selfParent->_children.begin() + selfIndex);
            selfParent->endRemoveRows();

            // Insert target into this
            beginInsertRows(QModelIndex(), count(), count());
            audioNode()->children().push(std::move(audioPtr));
            _children.push(std::move(ptr));
            endInsertRows();
            target->setParent(this);

            // Insert this into target parent
            targetParent->beginInsertRows(QModelIndex(), targetParent->count(), targetParent->count());
            targetParent->audioNode()->children().push(std::move(selfAudioPtr));
            targetParent->_children.push(std::move(selfPtr));
            targetParent->endInsertRows();
            setParent(targetParent);
        },
        [this, hasPaused] {
            if (hasPaused) {
                Scheduler::Get()->graph().wait();
                Scheduler::Get()->invalidateCurrentGraph();
                Scheduler::Get()->playImpl();
            } else
                Scheduler::Get()->invalidateCurrentGraph();
            processGraphChange();
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

int NodeModel::getChildIndex(NodeModel *node) const noexcept
{
    int idx = 0;

    for (const auto &child : _children) {
        if (child.get() == node)
            return idx;
        ++idx;
    }
    return -1;
}

QVector<NodeModel *> NodeModel::getAllChildren(void) noexcept
{
    QVector<NodeModel *> res;

    getAllChildrenImpl(res);
    return res;
}

void NodeModel::getAllChildrenImpl(QVector<NodeModel *> &res) noexcept
{
    res.push_back(this);
    for (auto &child : _children)
        child->getAllChildrenImpl(res);
}

void NodeModel::processGraphChange(void) const noexcept
{
    emit Application::Get()->project()->master()->graphChanged();
}
