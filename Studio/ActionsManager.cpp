/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager
 */

#include <QVariant>
#include <QQmlEngine>

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
        case Action::AddNote:
            return actionAddNote(type, event.data.value<ActionAddNote>());
        case Action::RemoveNote:
            return actionRemoveNote(type, event.data.value<ActionRemoveNote>());
        case Action::MoveNote:
            return actionMoveNote(type, event.data.value<ActionMoveNote>());
        default:
            return false;
    }

    return false;
}

bool ActionsManager::actionAddNote(const Type type, const ActionAddNote &action)
{
    auto &note = action.note;

    if (type == Type::Undo) {
        int idx = action.partition->findExact(Note(BeatRange(note.range.from, note.range.to), note.key, note.velocity, note.tuning));
        if (idx == -1) {
            qDebug() << "UNDO: actionAddNote error (idx == -1)";
            return false;
        }
        action.partition->remove(idx);
        qDebug() << "UNDO: actionAddNote success";
        return true;
    }

    if (type == Type::Redo) {
        action.partition->add({{Audio::Beat(note.range.from), Audio::Beat(note.range.to)},
                        Audio::Key(note.key),
                        Audio::Velocity(note.velocity),
                        Audio::Tuning(note.tuning)});
        qDebug() << "REDO: actionAddNote success";
        return true;
    }
    return false;
}

bool ActionsManager::actionRemoveNote(const Type type, const ActionRemoveNote &action)
{
    auto &note = action.note;
    if (type == Type::Undo) {
        action.partition->add({{Audio::Beat(note.range.from), Audio::Beat(note.range.to)},
                        Audio::Key(note.key),
                        Audio::Velocity(note.velocity),
                        Audio::Tuning(note.tuning)});
        qDebug() << "UNDO: actionRemoveNote success";
        return true;
    }

    if (type == Type::Redo) {
        int idx = action.partition->findExact(Note(BeatRange(note.range.from, note.range.to), note.key, note.velocity, note.tuning));
        if (idx == -1) {
            qDebug() << "REDO: actionRemoveNote error (idx == -1)";
            return false;
        }
        action.partition->remove(idx);
        qDebug() << "REDO: actionRemoveNote success";
        return true;
    }
    return true;
}

bool ActionsManager::actionMoveNote(const Type type, const ActionMoveNote &action)
{
    auto &note = action.note;
    auto &oldNote = action.oldNote;

    if (type == Type::Undo) {
        int idx = action.partition->findExact(Note(BeatRange(note.range.from, note.range.to), note.key, note.velocity, note.tuning));
        if (idx == -1) {
            qDebug() << "UNDO: actionMoveNote error (idx == -1)";
            return false;
        }
        action.partition->set(idx, {
                           {Audio::Beat(oldNote.range.from), Audio::Beat(oldNote.range.to)},
                            Audio::Key(oldNote.key),
                            Audio::Velocity(oldNote.velocity),
                            Audio::Tuning(oldNote.tuning)});
    }

    if (type == Type::Redo) {
        int idx = action.partition->findExact(Note(BeatRange(oldNote.range.from, oldNote.range.to), oldNote.key, oldNote.velocity, oldNote.tuning));
        if (idx == -1) {
            qDebug() << "UNDO: actionMoveNote error (idx == -1)";
            return false;
        }
        action.partition->set(idx, {
                           {Audio::Beat(note.range.from), Audio::Beat(note.range.to)},
                            Audio::Key(note.key),
                            Audio::Velocity(note.velocity),
                            Audio::Tuning(note.tuning)});

    }
    return true;
}

ActionAddNote ActionsManager::makeActionAddNote(PartitionModel *partition, int nodeID, int partitionID, const int from, const int to, const int key, const int velocity, const int tuning) const noexcept
{
    ActionAddNote action;
    action.partition = partition;
    action.nodeID = nodeID;
    action.partitionID = partitionID;
    action.note = Note({BeatRange(Audio::Beat(from), Audio::Beat(to)), Audio::Key(key), Audio::Velocity(velocity), Audio::Tuning(tuning)});
    return action;
}

ActionRemoveNote ActionsManager::makeActionRemoveNote(PartitionModel *partition, int nodeID, int partitionID, const int from, const int to, const int key, const int velocity, const int tuning) const noexcept
{
    ActionRemoveNote action;
    action.partition = partition;
    action.nodeID = nodeID;
    action.partitionID = partitionID;
    action.note = Note({BeatRange(Audio::Beat(from), Audio::Beat(to)), Audio::Key(key), Audio::Velocity(velocity), Audio::Tuning(tuning)});
    return action;
}

ActionMoveNote ActionsManager::makeActionMoveNote(PartitionModel *partition, int nodeID, int partitionID, const int oldFrom, const int from, const int oldTo, const int to, const int oldKey, const int key, const int oldVelocity, const int velocity, const int oldTuning, const int tuning) const noexcept
{
    ActionMoveNote action;
    action.partition = partition;
    action.nodeID = nodeID;
    action.partitionID = partitionID;
    action.oldNote = Note({BeatRange(Audio::Beat(oldFrom), Audio::Beat(oldTo)), Audio::Key(oldKey), Audio::Velocity(oldVelocity), Audio::Tuning(oldTuning)});
    action.note = Note({BeatRange(Audio::Beat(from), Audio::Beat(to)), Audio::Key(key), Audio::Velocity(velocity), Audio::Tuning(tuning)});
    return action;
}
