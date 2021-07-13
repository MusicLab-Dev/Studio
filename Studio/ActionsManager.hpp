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
};
Q_DECLARE_METATYPE(ActionNodeBase)

/** -- notes */
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

using ActionAddNotes = ActionNotesBase;
using ActionRemoveNotes = ActionNotesBase;

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

using ActionAddPartitions = ActionInstancesBase;
using ActionRemovePartitions = ActionInstancesBase;

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
    [[nodiscard]] ActionAddNotes makeActionAddNotes(PartitionModel *partition, const QVector<QVariantList> &args) const noexcept;
    [[nodiscard]] ActionAddNotes makeActionAddRealNotes(PartitionModel *partition, const QVector<Note> &args) const noexcept;
    [[nodiscard]] ActionRemoveNotes makeActionRemoveNotes(PartitionModel *partition, const QVector<QVariantList> &args) const noexcept;
    [[nodiscard]] ActionMoveNotes makeActionMoveNotes(PartitionModel *partition, const QVector<QVariantList> &args) const noexcept;
    [[nodiscard]] ActionAddPartitions makeActionAddPartitions(PartitionsModel *instances, const QVector<QVariantList> &args) const noexcept;
    [[nodiscard]] ActionRemovePartitions makeActionRemovePartitions(PartitionsModel *instances, const QVector<PartitionInstance> &args) const noexcept;
    [[nodiscard]] ActionMovePartitions makeActionMovePartitions(PartitionsModel *instances, const QVector<QVariantList> &args) const noexcept;

    /** @brief Slot On Node Deleted */
    void nodeDeleted(NodeModel *node) noexcept;

    /** @brief Slot On Partition Deleted */
    void nodePartitionDeleted(NodeModel *node, int partitionIndex) noexcept;

private:
    QVector<Event> _events {};
    int _index = 0;

    bool process(const Event &event, const Type type) noexcept;
    bool actionAddNotes(const Type type, const ActionAddNotes &action);
    bool actionRemoveNotes(const Type type, const ActionRemoveNotes &action);
    bool actionMoveNotes(const Type type, const ActionMoveNotes &action);
    bool actionAddPartitions(const Type type, const ActionAddPartitions &action);
    bool actionRemovePartitions(const Type type, const ActionRemovePartitions &action);
    bool actionMovePartitions(const Type type, const ActionMovePartitions &action);
};
