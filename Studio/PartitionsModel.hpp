/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionsModel class
 */

#pragma once

#include <vector>

#include <QAbstractListModel>
#include <Core/UniqueAlloc.hpp>
#include <Audio/Node.hpp>

#include "PartitionModel.hpp"
#include "PartitionInstancesModel.hpp"

class NodeModel;

/** @brief class that contaign a list of partitionModel */
class PartitionsModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(Beat latestInstance READ latestInstance NOTIFY latestInstanceChanged)
    Q_PROPERTY(PartitionInstancesModel *instances READ instances NOTIFY instancesChanged)

public:
    /** @brief Roles of each instance */
    enum class Roles : int {
        Partition = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit PartitionsModel(Audio::Partitions *partitions, NodeModel *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~PartitionsModel(void) noexcept override = default;

    /** @brief Get the parent node if it exists */
    [[nodiscard]] NodeModel *parentNode(void) noexcept
        { return reinterpret_cast<NodeModel *>(parent()); }


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get a beat range from internal list */
    [[nodiscard]] const PartitionModel *get(const int index) const noexcept_ndebug;
    [[nodiscard]] PartitionModel *get(const int idx) noexcept_ndebug
        { return const_cast<PartitionModel *>(const_cast<const PartitionsModel *>(this)->get(idx)); }


    /** @brief Get the current latest instance */
    [[nodiscard]] Beat latestInstance(void) const noexcept { return _latestInstance; }

    /** @brief Process a last instance change */
    void processLatestInstanceChange(void);


    /** @brief Get the PartitionInstances model */
    [[nodiscard]] PartitionInstancesModel *instances(void) noexcept { return _instances.get(); }
    [[nodiscard]] const PartitionInstancesModel *instances(void) const noexcept { return _instances.get(); }


    /** @brief Get the backend data */
    [[nodiscard]] Audio::Partitions *audioPartitions(void) noexcept { return _data; }
    [[nodiscard]] const Audio::Partitions *audioPartitions(void) const noexcept { return _data; }

public slots:
    /** @brief Return the count of element in the model */
    int count(void) const noexcept { return static_cast<int>(_partitions.size()); }

    /** @brief Add a children to the list */
    bool add(void);

    /** @brief Remove a children from the list */
    bool remove(const int index);

    /** @brief Move beatrange at index */
    bool move(const int from, const int to);

    /** @brief Get a single partition model */
    PartitionModel *getPartition(const int index) { return get(index); }

    /** @brief Adds a note event on the fly */
    void addOnTheFly(const NoteEvent &note, NodeModel *node, const quint32 partitionIndex);

    /** @brief Copy a partition instance that belongs to another PartitionsModel instance */
    bool foreignPartitionInstanceCopy(PartitionModel *partition, const PartitionInstance &instance);

signals:
    /** @brief Notify that the latest instance of partitions has changed */
    void latestInstanceChanged(void);

    /** @brief Notify that the intances model has changed */
    void instancesChanged(void);

public: // Allow external insert / remove
    using QAbstractListModel::beginRemoveRows;
    using QAbstractListModel::endRemoveRows;
    using QAbstractListModel::beginInsertRows;
    using QAbstractListModel::endInsertRows;

private:
    Audio::Partitions *_data { nullptr };
    Core::TinyVector<Core::UniqueAlloc<PartitionModel>> _partitions;
    Beat _latestInstance { 0u };
    Core::UniqueAlloc<PartitionInstancesModel> _instances;

    /** @brief Refresh internal models */
    void refreshPartitions(void);

    /** @brief Get an available name for a partition */
    [[nodiscard]] QString getAvailablePartitionName(void) const noexcept;
};
