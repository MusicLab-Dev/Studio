/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager listener
 */

#include <iostream>
#include <QVariant>
#include <QQmlEngine>
#include <QDebug>

#include "Base.hpp"

#include "ActionsManager.hpp"
#include "PartitionModel.hpp"

ActionsManager::ActionsManager(QObject *parent)
    : QObject(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

bool ActionsManager::push(const QVariant &data) noexcept
{
    Action action;

    if (data.userType() == qMetaTypeId<ActionAddNotes>())
        action = Action::AddNotes;
    else if (data.userType() == qMetaTypeId<ActionAddPartitions>())
        action = Action::AddPartitions;
    else if (data.userType() == qMetaTypeId<ActionRemoveNotes>())
        action = Action::RemoveNotes;
    else if (data.userType() == qMetaTypeId<ActionRemovePartitions>())
        action = Action::RemovePartitions;
    else if (data.userType() == qMetaTypeId<ActionMoveNotes>())
        action = Action::MoveNotes;
    else if (data.userType() == qMetaTypeId<ActionMovePartitions>())
        action = Action::MovePartitions;
    else if (data.userType() == qMetaTypeId<ActionMoveNode>())
        action = Action::MoveNode;
    else {
        qDebug() << "ActionsManager::push: Invalid action type";
        return false;
    }

    if (reinterpret_cast<const ActionNodeBase *>(data.data())->isDirty()) {
        qDebug() << "ActionsManager::push: Dirty action";
        return false;
    } else if (!_backwardCount) {
        _events.clear();
    } else if (_backwardCount < _events.size()) {
        _events.remove(_backwardCount, _events.size() - _backwardCount);
    }

    _events.push_back({ action, data });
    ++_backwardCount;
    return true;
}

bool ActionsManager::undo(void)
{
    if (_backwardCount == 0)
        return false;

    auto &event = current();
    --_backwardCount;
    bool done = false;

    switch (event.action) {
    case Action::AddNotes:
        done = undoAddNotes(event.data.value<ActionAddNotes>());
        break;
    case Action::RemoveNotes:
        done = undoRemoveNotes(event.data.value<ActionRemoveNotes>());
        break;
    case Action::MoveNotes:
        done = undoMoveNotes(event.data.value<ActionMoveNotes>());
        break;
    case Action::AddPartitions:
        done = undoAddPartitions(event.data.value<ActionAddPartitions>());
        break;
    case Action::RemovePartitions:
        done = undoRemovePartitions(event.data.value<ActionRemovePartitions>());
        break;
    case Action::MovePartitions:
        done = undoMovePartitions(event.data.value<ActionMovePartitions>());
        break;
    case Action::MoveNode:
        done = undoMoveNode(event.data.value<ActionMoveNode>());
        break;
    default:
        return false;
    }
    if (!done)
        ++_backwardCount;
    return done;
}

bool ActionsManager::redo(void)
{
    if (_backwardCount == _events.size())
        return false;

    ++_backwardCount;
    auto &event = current();
    bool done = false;

    switch (event.action) {
    case Action::AddNotes:
        done = redoAddNotes(event.data.value<ActionAddNotes>());
        break;
    case Action::RemoveNotes:
        done = redoRemoveNotes(event.data.value<ActionRemoveNotes>());
        break;
    case Action::MoveNotes:
        done = redoMoveNotes(event.data.value<ActionMoveNotes>());
        break;
    case Action::AddPartitions:
        done = redoAddPartitions(event.data.value<ActionAddPartitions>());
        break;
    case Action::RemovePartitions:
        done = redoRemovePartitions(event.data.value<ActionRemovePartitions>());
        break;
    case Action::MovePartitions:
        done = redoMovePartitions(event.data.value<ActionMovePartitions>());
        break;
    case Action::MoveNode:
        done = redoMoveNode(event.data.value<ActionMoveNode>());
        break;
    default:
        return false;
    }
    if (!done)
        --_backwardCount;
    return done;
}

bool ActionsManager::undoAddNotes(const ActionAddNotes &action)
{
    return action.partition->removeExactRange(action.notes);
}

bool ActionsManager::redoAddNotes(const ActionAddNotes &action)
{
    return action.partition->addRange(action.notes);
}

bool ActionsManager::undoRemoveNotes(const ActionRemoveNotes &action)
{
    return action.partition->addRange(action.notes);
}

bool ActionsManager::redoRemoveNotes(const ActionRemoveNotes &action)
{
    return action.partition->removeExactRange(action.notes);
}

bool ActionsManager::undoMoveNotes(const ActionMoveNotes &action)
{
    return action.partition->setRange(action.notes, action.oldNotes);
}

bool ActionsManager::redoMoveNotes(const ActionMoveNotes &action)
{
    return action.partition->setRange(action.oldNotes, action.notes);
}

bool ActionsManager::undoAddPartitions(const ActionAddPartitions &action)
{
    return action.partitions->instances()->removeExactRange(action.instances);
}

bool ActionsManager::redoAddPartitions(const ActionAddPartitions &action)
{
    return action.partitions->instances()->addRange(action.instances);
}

bool ActionsManager::undoRemovePartitions(const ActionRemovePartitions &action)
{
    return action.partitions->instances()->addRange(action.instances);
}

bool ActionsManager::redoRemovePartitions(const ActionRemovePartitions &action)
{
    return action.partitions->instances()->removeExactRange(action.instances);
}

bool ActionsManager::undoMovePartitions(const ActionMovePartitions &action)
{
    return action.partitions->instances()->setRange(action.instances, action.oldInstances);
}

bool ActionsManager::redoMovePartitions(const ActionMovePartitions &action)
{
    return action.partitions->instances()->setRange(action.oldInstances, action.instances);
}

bool ActionsManager::undoMoveNode(const ActionMoveNode &action)
{
    return action.lastParent->moveToChildren(action.node);
}

bool ActionsManager::redoMoveNode(const ActionMoveNode &action)
{
    return action.newParent->moveToChildren(action.node);
}

ActionAddNotes ActionsManager::makeActionAddNotes(PartitionModel *partition, const QVector<Note> &notes) const noexcept
{
    ActionAddNotes action;

    action.node = partition->parentPartitions()->parentNode();
    action.partition = partition;
    action.notes = notes;
    return action;
}

ActionRemoveNotes ActionsManager::makeActionRemoveNotes(PartitionModel *partition, const QVector<Note> &notes) const noexcept
{
    ActionRemoveNotes action;

    action.node = partition->parentPartitions()->parentNode();
    action.partition = partition;
    action.notes = notes;
    return action;
}

ActionMoveNotes ActionsManager::makeActionMoveNotes(PartitionModel *partition, const QVector<Note> &before, const QVector<Note> &after) const noexcept
{
    ActionMoveNotes action;

    if (before == after) {
        action.setDirty();
        return action;
    }
    action.node = partition->parentPartitions()->parentNode();
    action.partition = partition;
    action.notes = after;
    action.oldNotes = before;
    return action;
}


ActionAddPartitions ActionsManager::makeActionAddPartitions(PartitionsModel *partitions, const QVector<PartitionInstance> &instances) const noexcept
{
    ActionAddPartitions action;

    action.node = partitions->parentNode();
    action.partitions = partitions;
    action.instances = instances;
    return action;
}

ActionRemovePartitions ActionsManager::makeActionRemovePartitions(PartitionsModel *partitions, const QVector<PartitionInstance> &instances) const noexcept
{
    ActionRemovePartitions action;

    action.node = partitions->parentNode();
    action.partitions = partitions;
    action.instances = instances;
    return action;
}

ActionMovePartitions ActionsManager::makeActionMovePartitions(PartitionsModel *partitions, const QVector<PartitionInstance> &before, const QVector<PartitionInstance> &after) const noexcept
{
    ActionMovePartitions action;


    if (before == after) {
        action.setDirty();
        return action;
    }
    action.node = partitions->parentNode();
    action.partitions = partitions;
    action.instances = after;
    action.oldInstances = before;
    return action;
}

ActionMoveNode ActionsManager::makeActionMoveNode(NodeModel *node, NodeModel *lastParent, NodeModel *newParent) const noexcept
{
    ActionMoveNode action;

    qDebug() << node->name() << lastParent->name() << newParent->name();

    action.node = node;
    action.lastParent = lastParent;
    action.newParent = newParent;
    return action;
}

void ActionsManager::nodeDeleted(NodeModel *node) noexcept
{
    const auto it = std::remove_if(_events.begin(), _events.end(), [node](const Event &elem) {
        switch (elem.action) {
        case Action::MoveNode:
            return false; // @todo Change this when MoveNode is implemented
        default:
        {
            const auto *it = reinterpret_cast<const ActionNodeBase *>(elem.data.data());
            return it->node == node || node->isAParent(it->node);
        }
        }
    });
    if (it != _events.end())
        _events.erase(it, _events.end());
}

void ActionsManager::nodePartitionDeleted(NodeModel *node, int partitionIndex) noexcept
{
    const auto partition = node->partitions()->getPartition(partitionIndex);
    const auto it = std::remove_if(_events.begin(), _events.end(), [node, partition](const Event &elem) {
        switch (elem.action) {
        case Action::AddPartitions:
        case Action::RemoveNotes:
        case Action::RemovePartitions:
        case Action::MoveNotes:
        case Action::MovePartitions:
        {
            const auto *it = reinterpret_cast<const ActionPartitionBase *>(elem.data.data());
            return it->node == node && it->partition == partition;
        }
        default:
            return false;
        }
    });

    if (it != _events.end())
        _events.erase(it, _events.end());
}
