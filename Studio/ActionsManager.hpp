/**
 * @ Author: Cédric Lucchese
 * @ Description: Actions Manager listener
 */

#pragma once

#include <QObject>

#include "Note.hpp"
#include "NodeModel.hpp"
#include "PartitionModel.hpp"
#include "PartitionsModel.hpp"
#include "PartitionInstancesModel.hpp"

struct ActionNodeBase
{
    NodeModel *node { nullptr };

    /** @brief Dirty state used to discard an action when pushed */
    [[nodiscard]] bool isDirty(void) const noexcept { return !node; }
    void setDirty(void) noexcept { node = nullptr; }
};
Q_DECLARE_METATYPE(ActionNodeBase)

/** -- Nodes --  */
struct ActionMoveNode : public ActionNodeBase
{
    NodeModel *lastParent { nullptr };
    NodeModel *newParent { nullptr };
};
Q_DECLARE_METATYPE(ActionMoveNode)

/** -- Notes --  */
struct ActionPartitionBase : public ActionNodeBase
{
    PartitionModel *partition { nullptr };
};
Q_DECLARE_METATYPE(ActionPartitionBase)

struct ActionNotesBase : public ActionPartitionBase
{
    QVector<Note> notes;
};
Q_DECLARE_METATYPE(ActionNotesBase)

struct ActionAddNotes : public ActionNotesBase {};
Q_DECLARE_METATYPE(ActionAddNotes)

struct ActionRemoveNotes : public ActionNotesBase {};
Q_DECLARE_METATYPE(ActionRemoveNotes)

struct ActionMoveNotes : public ActionNotesBase
{
    QVector<Note> oldNotes;
};
Q_DECLARE_METATYPE(ActionMoveNotes)

/** -- Partitions -- */
struct ActionPartitionsBase : public ActionNodeBase
{
    PartitionsModel *partitions { nullptr };
};
Q_DECLARE_METATYPE(ActionPartitionsBase)

struct ActionInstancesBase : public ActionPartitionsBase
{
    QVector<PartitionInstance> instances;
};
Q_DECLARE_METATYPE(ActionInstancesBase)

struct ActionAddPartitions : public ActionInstancesBase {};
Q_DECLARE_METATYPE(ActionAddPartitions)

struct ActionRemovePartitions : public ActionInstancesBase {};
Q_DECLARE_METATYPE(ActionRemovePartitions)

struct ActionMovePartitions : public ActionInstancesBase
{
    QVector<PartitionInstance> oldInstances;
};
Q_DECLARE_METATYPE(ActionMovePartitions)


/** @brief Actions Manager class */
class ActionsManager : public QObject
{
    Q_OBJECT

public:
    enum class Action {
        None = 0,

        // Add
        AddNotes,
        AddPartitions,

        // Remove
        RemoveNotes,
        RemovePartitions,

        // Move
        MoveNotes,
        MovePartitions,
        MoveNode
    };
    Q_ENUM(Action);

    struct Event
    {
        Action action { Action::None };
        QVariant data {};
    };

    /** @brief Default constructor */
    explicit ActionsManager(QObject *parent = nullptr);

    /** @brief get current event */
    [[nodiscard]] const Event &current(void) const noexcept { return _events[_backwardCount - 1]; }
    [[nodiscard]] Event &current(void) noexcept { return _events[_backwardCount - 1]; }

public slots:
    /** @brief Push a new event in the stack */
    bool push(const QVariant &data) noexcept;

    /** @brief Process the undo */
    bool undo(void);

    /** @brief Process the redo */
    bool redo(void);

    /** @brief Nodes wrappers */
    [[nodiscard]] ActionMoveNode makeActionMoveNode(NodeModel *node, NodeModel *lastParent, NodeModel *newParent) const noexcept;

    /** @brief Notes wrappers */
    [[nodiscard]] ActionAddNotes makeActionAddNotes(PartitionModel *partition, const QVector<Note> &notes) const noexcept;
    [[nodiscard]] ActionRemoveNotes makeActionRemoveNotes(PartitionModel *partition, const QVector<Note> &notes) const noexcept;
    [[nodiscard]] ActionMoveNotes makeActionMoveNotes(PartitionModel *partition, const QVector<Note> &before, const QVector<Note> &after) const noexcept;

    /** @brief Partition instances wrappers */
    [[nodiscard]] ActionAddPartitions makeActionAddPartitions(PartitionsModel *partitions, const QVector<PartitionInstance> &instances) const noexcept;
    [[nodiscard]] ActionRemovePartitions makeActionRemovePartitions(PartitionsModel *partitions, const QVector<PartitionInstance> &instances) const noexcept;
    [[nodiscard]] ActionMovePartitions makeActionMovePartitions(PartitionsModel *partitions, const QVector<PartitionInstance> &before, const QVector<PartitionInstance> &after) const noexcept;

    /** @brief Slot On Node Deleted */
    void nodeDeleted(NodeModel *node) noexcept;

    /** @brief Slot On Partition Deleted */
    void nodePartitionDeleted(NodeModel *node, int partitionIndex) noexcept;

private:
    QVector<Event> _events {};
    int _backwardCount = 0;

    /** @brief Action handlers */
    [[nodiscard]] bool undoMoveNode(const ActionMoveNode &action);
    [[nodiscard]] bool redoMoveNode(const ActionMoveNode &action);
    [[nodiscard]] bool undoAddNotes(const ActionAddNotes &action);
    [[nodiscard]] bool redoAddNotes(const ActionAddNotes &action);
    [[nodiscard]] bool undoRemoveNotes(const ActionRemoveNotes &action);
    [[nodiscard]] bool redoRemoveNotes(const ActionRemoveNotes &action);
    [[nodiscard]] bool undoMoveNotes(const ActionMoveNotes &action);
    [[nodiscard]] bool redoMoveNotes(const ActionMoveNotes &action);
    [[nodiscard]] bool undoAddPartitions(const ActionAddPartitions &action);
    [[nodiscard]] bool redoAddPartitions(const ActionAddPartitions &action);
    [[nodiscard]] bool undoRemovePartitions(const ActionRemovePartitions &action);
    [[nodiscard]] bool redoRemovePartitions(const ActionRemovePartitions &action);
    [[nodiscard]] bool undoMovePartitions(const ActionMovePartitions &action);
    [[nodiscard]] bool redoMovePartitions(const ActionMovePartitions &action);
};
