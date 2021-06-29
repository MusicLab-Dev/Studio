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

struct ActionNotesBase : public ActionPartitionBase
{
    QVector<Note> notes;
};
Q_DECLARE_METATYPE(ActionNotesBase)

using ActionAddNotes = ActionNotesBase;
using ActionRemoveNotes = ActionNotesBase;

struct ActionMoveNotes : public ActionNotesBase
{
    QVector<Note> oldNotes;
};
Q_DECLARE_METATYPE(ActionMoveNotes)


/** @brief Actions Manager class */
class ActionsManager : public QObject
{
    Q_OBJECT

public:
    enum class Action {
        None = 0,

        // Add
        AddNotes,
        AddPartition,
        AddNode,

        // Remove
        RemoveNotes,
        RemovePartition,
        RemoveNode,
        
        // Move
        MoveNotes,
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
    explicit ActionsManager(QObject *parent = nullptr);

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
    [[nodiscard]] ActionAddNotes makeActionAddNotes(PartitionModel *partition, int nodeID, int partitionID, const QVector<QVariantList> &args) const noexcept;
    [[nodiscard]] ActionRemoveNotes makeActionRemoveNotes(PartitionModel *partition, int nodeID, int partitionID, const QVector<QVariantList> &args) const noexcept;
    [[nodiscard]] ActionMoveNotes makeActionMoveNotes(PartitionModel *partition, int nodeID, int partitionID, const QVector<QVariantList> &args) const noexcept;

private:
    QVector<Event> _events {};
    int _index = 0;

    bool process(const Event &event, const Type type) noexcept;
    bool actionAddNotes(const Type type, const ActionAddNotes &action);
    bool actionRemoveNotes(const Type type, const ActionRemoveNotes &action);
    bool actionMoveNotes(const Type type, const ActionMoveNotes &action);
};
