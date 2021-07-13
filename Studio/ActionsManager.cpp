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

bool ActionsManager::push(const Action action, const QVariant &data) noexcept
{ 
    if (_events.size() > _index + 1)
        _events.remove(_index, _events.size() - _index);
    
    qDebug() << _events.size() << action << data;

    _events.push_back({action, data});
    _index++;
    return true;
}


/** @brief Process the undo */
bool ActionsManager::undo(void) noexcept
{
    if (_index <= 0)
        return false;

    auto &event = current();
    _index--;

    return process(event, Type::Undo);
}

/** @brief Process the redo */
bool ActionsManager::redo(void) noexcept
{
    if (_index >= _events.size())
        return false;

    _index++;
    auto &event = current();

    return process(event, Type::Redo);
}

bool ActionsManager::process(const Event &event, const Type type) noexcept
{
    switch (event.action)
    {
        case Action::AddNotes:
            return actionAddNotes(type, event.data.value<ActionAddNotes>());
        case Action::RemoveNotes:
            return actionRemoveNotes(type, event.data.value<ActionRemoveNotes>());
        case Action::MoveNotes:
            return actionMoveNotes(type, event.data.value<ActionMoveNotes>());
        case Action::AddPartitions:
            return actionAddPartitions(type, event.data.value<ActionAddPartitions>());
        case Action::RemovePartitions:
            return actionRemovePartitions(type, event.data.value<ActionRemovePartitions>());
        case Action::MovePartitions:
            return actionMovePartitions(type, event.data.value<ActionMovePartitions>());
        default:
            return false;
    }

    return false;
}

bool ActionsManager::actionAddNotes(const Type type, const ActionAddNotes &action)
{
    auto &notes = action.notes;

    if (type == Type::Undo) {
        QVariantList indexes;
        for (auto &note : notes) {
            int idx = action.partition->findExact(note);
            if (idx == -1) {
                qDebug() << "UNDO: actionAddNote error (idx == -1)";
                continue;
            }
            indexes.push_back(idx);
        }
        action.partition->removeRange(indexes);
        qDebug() << "UNDO: actionAddNote success";
        return true;
    }

    if (type == Type::Redo) {
        action.partition->addRange(notes);
        qDebug() << "UNDO: actionRemoveNote success";
        return true;
    }
    return false;
}

bool ActionsManager::actionRemoveNotes(const Type type, const ActionRemoveNotes &action)
{
    auto &notes = action.notes;

    if (type == Type::Undo) {
        action.partition->addRange(notes);
        qDebug() << "UNDO: actionRemoveNote success";
        return true;
    }

    if (type == Type::Redo) {
        QVariantList indexes;
        for (auto &note : notes) {
            int idx = action.partition->findExact(note);
            if (idx == -1) {
                qDebug() << "UNDO: actionAddNote error (idx == -1)";
                continue;
            }
            indexes.push_back(idx);
        }
        action.partition->removeRange(indexes);
        qDebug() << "UNDO: actionAddNote success";
        return true;
    }
    return false;
}

bool ActionsManager::actionMoveNotes(const Type type, const ActionMoveNotes &action)
{
    auto &notes = action.notes;
    auto &oldNotes = action.oldNotes;

    if (type == Type::Undo) {
        for (int i = 0; i < notes.size() && i < oldNotes.size(); i++) {
            auto &note = notes[i];
            auto &oldNote = oldNotes[i];
            int idx = action.partition->findExact(note);
            if (idx == -1) {
                qDebug() << "UNDO: actionMoveNote error (idx == -1)";
                continue;
            }
            action.partition->set(idx, oldNote);
        }
        qDebug() << "UNDO: actionMoveNote success";
        return true;
    }

/*
    if (type == Type::Redo) {
        for (int i = 0; i < notes.size() && i < oldNotes.size(); i++) {
            auto &note = notes[i];
            auto &oldNote = oldNotes[i];
            int idx = action.partition->findExact(Note(BeatRange(oldNote.range.from, oldNote.range.to), oldNote.key, oldNote.velocity, oldNote.tuning));
            if (idx == -1) {
                qDebug() << "REDO: actionMoveNote error (idx == -1)";
                return false;
            }
            action.partition->set(idx, {
                               {Audio::Beat(note.range.from), Audio::Beat(note.range.to)},
                                Audio::Key(note.key),
                                Audio::Velocity(note.velocity),
                                Audio::Tuning(note.tuning)});
        }
        qDebug() << "REDO: actionMoveNote success";
        return true;
    }*/
    return false;
}

bool ActionsManager::actionAddPartitions(const Type type, const ActionAddPartitions &action)
{
    auto &instances = action.instances;

    if (type == Type::Undo) {
        QVariantList indexes;
        for (auto &instance : instances) {
            int idx = action.partitions->instances()->findExact(instance);
            if (idx == -1) {
                qDebug() << "UNDO: actionAddPartitions error (idx == -1)";
                continue;
            }
            indexes.push_back(idx);
        }
        action.partitions->instances()->removeRange(indexes);
        qDebug() << "UNDO: actionAddPartitions success";
        return true;
    }

    if (type == Type::Redo) {
        action.partitions->instances()->addRealRange(instances);
        qDebug() << "UNDO: actionRemoveNote success";
        return true;
    }
    return false;
}

bool ActionsManager::actionRemovePartitions(const Type type, const ActionRemovePartitions &action)
{
    auto &instances = action.instances;

    if (type == Type::Undo) {
        action.partitions->instances()->addRealRange(instances);
        qDebug() << "UNDO: actionRemovePartitions success";
        return true;
    }

    if (type == Type::Redo) {
        for (auto &instance : instances) {
            auto idx = action.partitions->instances()->findExact(instance);
            action.partitions->instances()->remove(idx);
        }
        qDebug() << "REDO: actionRemovePartitions success";
        return true;
    }
    return false;
}

bool ActionsManager::actionMovePartitions(const Type type, const ActionMovePartitions &action)
{
    /*
    auto &notes = action.notes;
    auto &oldNotes = action.oldNotes;

    if (type == Type::Undo) {
        for (int i = 0; i < notes.size() && i < oldNotes.size(); i++) {
            auto &note = notes[i];
            auto &oldNote = oldNotes[i];
            int idx = action.partition->findExact(Note(BeatRange(note.range.from, note.range.to), note.key, note.velocity, note.tuning));
            if (idx == -1) {
                qDebug() << "UNDO: actionMoveNote error (idx == -1)";
                continue;
            }
            action.partition->set(idx, {
                               {Audio::Beat(oldNote.range.from), Audio::Beat(oldNote.range.to)},
                                Audio::Key(oldNote.key),
                                Audio::Velocity(oldNote.velocity),
                                Audio::Tuning(oldNote.tuning)});
        }
        qDebug() << "UNDO: actionMoveNote success";
        return true;
    }

    if (type == Type::Redo) {
        for (int i = 0; i < notes.size() && i < oldNotes.size(); i++) {
            auto &note = notes[i];
            auto &oldNote = oldNotes[i];
            int idx = action.partition->findExact(Note(BeatRange(oldNote.range.from, oldNote.range.to), oldNote.key, oldNote.velocity, oldNote.tuning));
            if (idx == -1) {
                qDebug() << "REDO: actionMoveNote error (idx == -1)";
                return false;
            }
            action.partition->set(idx, {
                               {Audio::Beat(note.range.from), Audio::Beat(note.range.to)},
                                Audio::Key(note.key),
                                Audio::Velocity(note.velocity),
                                Audio::Tuning(note.tuning)});
        }
        qDebug() << "REDO: actionMoveNote success";
        return true;
    }
    */
    return false;
}


ActionAddNotes ActionsManager::makeActionAddNotes(PartitionModel *partition, const QVector<QVariantList> &args) const noexcept
{
    ActionAddNotes action;
    action.partition = partition;
    action.node = partition->parentPartitions()->parentNode();

    for (auto &elem : args) {
        action.notes.push_back(
            Note({BeatRange(Audio::Beat(elem[0].toInt()), Audio::Beat(elem[1].toInt())), Audio::Key(elem[2].toInt()), Audio::Velocity(elem[3].toInt()), Audio::Tuning(elem[4].toInt())})
        );
    }
    return action;
}

ActionAddNotes ActionsManager::makeActionAddRealNotes(PartitionModel *partition, const QVector<Note> &args) const noexcept
{
    ActionAddNotes action;
    action.partition = partition;
    action.node = partition->parentPartitions()->parentNode();
    action.notes = args;
    return action;
}

ActionRemoveNotes ActionsManager::makeActionRemoveNotes(PartitionModel *partition, const QVector<QVariantList> &args) const noexcept
{
    ActionRemoveNotes action;
    action.partition = partition;
    action.node = partition->parentPartitions()->parentNode();

    for (auto &elem : args) {
        action.notes.push_back(
            Note({BeatRange(Audio::Beat(elem[0].toInt()), Audio::Beat(elem[1].toInt())), Audio::Key(elem[2].toInt()), Audio::Velocity(elem[3].toInt()), Audio::Tuning(elem[4].toInt())})
        );
    }
    return action;
}

ActionMoveNotes ActionsManager::makeActionMoveNotes(PartitionModel *partition,  const QVector<QVariantList> &args) const noexcept
{
    ActionMoveNotes action;
    action.partition = partition;
    action.node = partition->parentPartitions()->parentNode();

    for (auto &elem : args) {
        action.oldNotes.push_back(
            Note({BeatRange(Audio::Beat(elem[0].toInt()), Audio::Beat(elem[2].toInt())), Audio::Key(elem[4].toInt()), Audio::Velocity(elem[6].toInt()), Audio::Tuning(elem[8].toInt())})
        );
        action.notes.push_back(
            Note({BeatRange(Audio::Beat(elem[1].toInt()), Audio::Beat(elem[3].toInt())), Audio::Key(elem[5].toInt()), Audio::Velocity(elem[7].toInt()), Audio::Tuning(elem[9].toInt())})
        );
    }
    return action;
}

ActionAddPartitions ActionsManager::makeActionAddPartitions(PartitionsModel *partitions, const QVector<QVariantList> &args) const noexcept
{
    ActionAddPartitions action;
    action.partitions = partitions;
    action.node = partitions->parentNode();

    for (auto &elem : args) {
        action.instances.push_back(
            PartitionInstance({
                                  quint32(elem[0].toInt()),
                                  Audio::Beat(elem[1].toInt()),
                                  Audio::BeatRange({
                                      Audio::Beat(elem[2].toInt()), Audio::Beat(elem[3].toInt())
                                  })
                              })
        );
    }
    return action;
}

ActionRemovePartitions ActionsManager::makeActionRemovePartitions(PartitionsModel *partitions, const QVector<PartitionInstance> &args) const noexcept
{
    ActionAddPartitions action;
    action.partitions = partitions;
    action.node = partitions->parentNode();

    for (auto &elem : args)
        action.instances.push_back(elem);
    return action;
}

ActionMovePartitions ActionsManager::makeActionMovePartitions(PartitionsModel *partitionInstances,  const QVector<QVariantList> &args) const noexcept
{
    ActionMovePartitions action;
    /*action.partition = partition;
    action.node = partition->parentPartitions()->parentNode();

    for (auto &elem : args) {
        action.oldNotes.push_back(
            Note({BeatRange(Audio::Beat(elem[0].toInt()), Audio::Beat(elem[2].toInt())), Audio::Key(elem[4].toInt()), Audio::Velocity(elem[6].toInt()), Audio::Tuning(elem[8].toInt())})
        );
        action.notes.push_back(
            Note({BeatRange(Audio::Beat(elem[1].toInt()), Audio::Beat(elem[3].toInt())), Audio::Key(elem[5].toInt()), Audio::Velocity(elem[7].toInt()), Audio::Tuning(elem[9].toInt())})
        );
    }*/
    return action;
}


void ActionsManager::nodeDeleted(NodeModel *node) noexcept
{
    const auto it = std::remove_if(_events.begin(), _events.end(), [node](const Event &elem) {
        switch (elem.action) {
        case Action::MoveNode:
            return false;
        default:
            const auto *it = reinterpret_cast<const ActionNodeBase *>(elem.data.data());
            return it->node == node || node->isAParent(it->node);
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
        case Action::AddNotes:
        case Action::AddPartitions:
        case Action::RemoveNotes:
        case Action::RemovePartitions:
        case Action::MoveNotes:
        case Action::MovePartitions:
            const auto *it = reinterpret_cast<const ActionPartitionBase *>(elem.data.data());
            return it->node == node && it->partition == partition;
        }
        return false;
    });

    if (it != _events.end())
        _events.erase(it, _events.end());
}
