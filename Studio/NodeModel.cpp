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
static quint32 CurrentRedColorIndex = 0u;
static quint32 CurrentGreenColorIndex = 0u;
static quint32 CurrentBlueColorIndex = 0u;

NodeModel::NodeModel(Audio::Node *node, QObject *parent) noexcept
    :   QAbstractListModel(parent),
        _data(node),
        _partitions(&node->partitions(), this),
        _automations(&node->automations(), this),
        _plugin(node->plugin(), this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);

    // Set color using plugin tags
    ThemeManager::SubChain subChain {};
    quint32 index = 0u;
    if (static_cast<int>(_plugin->tags()) & static_cast<int>(PluginModel::Tags::Instrument)) {
        subChain = ThemeManager::SubChain::Blue;
        index = CurrentBlueColorIndex++;
    } else if (static_cast<int>(_plugin->tags()) & static_cast<int>(PluginModel::Tags::Effect)) {
        subChain = ThemeManager::SubChain::Red;
        index = CurrentRedColorIndex++;
    } else {
        subChain = ThemeManager::SubChain::Green;
        index = CurrentGreenColorIndex++;
    }
    _data->setColor(ThemeManager::GetColorFromSubChain(subChain, index).rgba());
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

void NodeModel::setParentNode(NodeModel * const parent) noexcept
{
    if (this->parent() == parent)
        return;
    setParent(parent);
    if (parent)
        audioNode()->setParent(parent->audioNode());
    else
        audioNode()->setParent(nullptr);
    emit parentNodeChanged();
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
            auto targetParent = target->parentNode();

            // Extract target node from targetParent
            auto [ptr, audioPtr] = ProcessRemove(targetParent, targetIndex);

            // Insert target into children
            ProcessAdd(this, std::move(ptr), std::move(audioPtr));
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
            const auto selfParent = this->parentNode();

            // Extract target node from targetParent
            auto [ptr, audioPtr] = ProcessRemove(targetParent, targetIndex);

            // Extract self from self parent
            const auto selfIndex = selfParent->getChildIndex(this);
            auto [selfPtr, selfAudioPtr] = ProcessRemove(selfParent, selfIndex);

            // Insert target into this
            ProcessAdd(this, std::move(ptr), std::move(audioPtr));

            // Insert this into target parent
            ProcessAdd(targetParent, std::move(selfPtr), std::move(selfAudioPtr));
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

bool NodeModel::swapNodes(NodeModel *target)
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
            const auto selfParent = this->parentNode();
            const auto targetParent = target->parentNode();

            // If parents are same, only swap children
            if (selfParent == targetParent) {
                beginResetModel();
                target->beginResetModel();
                ProcessSwap(this, target);
                target->endResetModel();
                endResetModel();
                return;
            }

            // Extract target node from targetParent
            auto [ptr, audioPtr] = ProcessRemove(targetParent, targetIndex);

            // Extract self from self parent
            const auto selfIndex = selfParent->getChildIndex(this);
            auto [selfPtr, selfAudioPtr] = ProcessRemove(selfParent, selfIndex);

            // Switch children
            ProcessSwap(this, target);

            // Insert target into self parent
            if (target != selfParent)
                ProcessAdd(selfParent, std::move(ptr), std::move(audioPtr));
            else
                ProcessAdd(this, std::move(ptr), std::move(audioPtr));

            // Insert this into target parent
            if (this != targetParent)
                ProcessAdd(targetParent, std::move(selfPtr), std::move(selfAudioPtr));
            else
                ProcessAdd(target, std::move(selfPtr), std::move(selfAudioPtr));
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

bool NodeModel::duplicate(void)
{
    NodeModel *parent = parentNode();

    if (!parent)
        return false;
    NodeModel *node = parent->add(plugin()->path());
    node->setName(name());
    node->setColor(color());
    return true;
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


void NodeModel::ProcessSwap(NodeModel * const lhs, NodeModel *rhs)
{
    lhs->audioNode()->children().swap(rhs->audioNode()->children());
    lhs->_children.swap(rhs->_children);
    for (auto &child : lhs->_children)
        child->setParentNode(lhs);
    for (auto &child : rhs->_children)
        child->setParentNode(rhs);
}

void NodeModel::ProcessAdd(NodeModel * const parent, NodePtr &&nodePtr, Audio::NodePtr &&audioNodePtr)
{
    parent->beginInsertRows(QModelIndex(), parent->count(), parent->count());
    parent->audioNode()->children().push(std::move(audioNodePtr));
    parent->_children.push(std::move(nodePtr))
        ->setParent(parent);
    parent->endInsertRows();
}

std::pair<NodeModel::NodePtr, Audio::NodePtr> NodeModel::ProcessRemove(NodeModel * const parent, const int targetIndex)
{
    auto &ref = parent->_children.at(targetIndex);
    const auto target = ref.get();
    parent->beginRemoveRows(QModelIndex(), targetIndex, targetIndex);
    auto audioPtr = std::move(parent->audioNode()->children().at(static_cast<std::uint32_t>(targetIndex)));
    auto ptr = std::move(ref);
    parent->audioNode()->children().erase(parent->audioNode()->children().begin() + targetIndex);
    parent->_children.erase(parent->_children.begin() + targetIndex);
    parent->endRemoveRows();
    target->setParentNode(nullptr);
    return std::make_pair(std::move(ptr), std::move(audioPtr));
}
