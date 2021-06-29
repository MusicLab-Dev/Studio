/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager listener
 */

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
        default:
            return false;
    }

    return false;
}

bool ActionsManager::actionAddNotes(const Type type, const ActionAddNotes &action)
{
    auto &notes = action.notes;

    if (type == Type::Undo) {
        for (auto &note : notes) {
            int idx = action.partition->findExact(Note(BeatRange(note.range.from, note.range.to), note.key, note.velocity, note.tuning));
            if (idx == -1) {
                qDebug() << "UNDO: actionAddNote error (idx == -1)";
                continue;
            }
            action.partition->remove(idx);
        }
        qDebug() << "UNDO: actionAddNote success";
        return true;
    }

    if (type == Type::Redo) {
        for (auto &note : notes) {
            action.partition->add({{Audio::Beat(note.range.from), Audio::Beat(note.range.to)},
                            Audio::Key(note.key),
                            Audio::Velocity(note.velocity),
                            Audio::Tuning(note.tuning)});
        }
        qDebug() << "REDO: actionAddNote success";
        return true;
    }
    return false;
}

bool ActionsManager::actionRemoveNotes(const Type type, const ActionRemoveNotes &action)
{
    auto &notes = action.notes;

    if (type == Type::Undo) {
        for (auto &note : notes) {
            action.partition->add({{Audio::Beat(note.range.from), Audio::Beat(note.range.to)},
                            Audio::Key(note.key),
                            Audio::Velocity(note.velocity),
                            Audio::Tuning(note.tuning)});
        }
        qDebug() << "UNDO: actionRemoveNote success";
        return true;
    }

    if (type == Type::Redo) {
        for (auto &note : notes) {
            int idx = action.partition->findExact(Note(BeatRange(note.range.from, note.range.to), note.key, note.velocity, note.tuning));
            if (idx == -1) {
                qDebug() << "REDO: actionRemoveNote error (idx == -1)";
                continue;
            }
            action.partition->remove(idx);
        }
        qDebug() << "REDO: actionRemoveNote success";
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
    return false;
}

ActionAddNotes ActionsManager::makeActionAddNotes(PartitionModel *partition, int nodeID, int partitionID, const QVector<QVariantList> &args) const noexcept
{
    ActionAddNotes action;
    action.partition = partition;
    action.nodeID = nodeID;
    action.partitionID = partitionID;

    for (auto &elem : args) {
        action.notes.push_back(
            Note({BeatRange(Audio::Beat(elem[0].toInt()), Audio::Beat(elem[1].toInt())), Audio::Key(elem[2].toInt()), Audio::Velocity(elem[3].toInt()), Audio::Tuning(elem[4].toInt())})
        );
    }
    return action;
}

ActionRemoveNotes ActionsManager::makeActionRemoveNotes(PartitionModel *partition, int nodeID, int partitionID, const QVector<QVariantList> &args) const noexcept
{
    ActionRemoveNotes action;
    action.partition = partition;
    action.nodeID = nodeID;
    action.partitionID = partitionID;

    for (auto &elem : args) {
        action.notes.push_back(
            Note({BeatRange(Audio::Beat(elem[0].toInt()), Audio::Beat(elem[1].toInt())), Audio::Key(elem[2].toInt()), Audio::Velocity(elem[3].toInt()), Audio::Tuning(elem[4].toInt())})
        );
    }
    return action;
}

ActionMoveNotes ActionsManager::makeActionMoveNotes(PartitionModel *partition, int nodeID, int partitionID, const QVector<QVariantList> &args) const noexcept
{
    ActionMoveNotes action;
    action.partition = partition;
    action.nodeID = nodeID;
    action.partitionID = partitionID;

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
