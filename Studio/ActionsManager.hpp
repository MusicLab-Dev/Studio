/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager listener
 */

#pragma once

#include <QObject>

#include "Note.hpp"
#include "PartitionModel.hpp"

struct ActionNodeBase
{
    int nodeID;
};
Q_DECLARE_METATYPE(ActionNodeBase)

struct ActionPartitionBase : public ActionNodeBase
{
    int partitionID;

    //DEBUG
    PartitionModel *partition;
};
Q_DECLARE_METATYPE(ActionPartitionBase)

struct ActionNoteBase : public ActionPartitionBase
{
    Note note;
};
Q_DECLARE_METATYPE(ActionNoteBase)

using ActionAddNote = ActionNoteBase;
using ActionRemoveNote = ActionNoteBase;

struct ActionMoveNote : public ActionNoteBase
{
    Note oldNote;
};
Q_DECLARE_METATYPE(ActionMoveNote)


/** @brief Actions Manager class */
class ActionsManager : public QObject
{
    Q_OBJECT

public:
    enum class Action {
        None = 0,

        // Add
        AddNote,
        AddPartition,
        AddNode,

        // Remove
        RemoveNote,
        RemovePartition,
        RemoveNode,
        
        // Move
        MoveNote,
        MovePartition,
        MoveNode,
    };
    Q_ENUM(Action);

    enum class Type {
        Undo,
        Redo
    };

    struct Event
    {
        Action action { Action::None };
        QVariant data {};
    };

    /** @brief Default constructor */
    explicit ActionsManager(void);

    /** @brief get current event */
    [[nodiscard]] const Event &current(void) const noexcept { return _events[_index - 1]; }
    [[nodiscard]] Event &current(void) noexcept { return _events[_index - 1]; }

public slots:
    /** @brief Push a new event in the stack */
    bool push(const Action action, const QVariant &data) noexcept;
    
    /** @brief Process the undo */
    bool undo(void) noexcept;

    /** @brief Process the redo */
    bool redo(void) noexcept;

    /** @brief Wrappers */
    [[nodiscard]] ActionAddNote makeActionAddNote(PartitionModel *partition, int nodeID, int partitionID, const int from, const int to, const int key, const int velocity, const int tuning) const noexcept;
    [[nodiscard]] ActionRemoveNote makeActionRemoveNote(PartitionModel *partition, int nodeID, int partitionID, const int from, const int to, const int key, const int velocity, const int tuning) const noexcept;
    [[nodiscard]] ActionMoveNote makeActionMoveNote(PartitionModel *partition, int nodeID, int partitionID, const int oldFrom, const int from, const int oldTo, const int to, const int oldKey, const int key, const int oldVelocity, const int velocity, const int oldTuning, const int tuning) const noexcept;

private:
    QVector<Event> _events {};
    int _index = 0;

    bool process(const Event &event, const Type type) noexcept;
    bool actionAddNote(const Type type, const ActionAddNote &action);
    bool actionRemoveNote(const Type type, const ActionRemoveNote &action);
    bool actionMoveNote(const Type type, const ActionMoveNote &action);
};
