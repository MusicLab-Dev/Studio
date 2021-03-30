/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionsModel class
 */

#pragma once

#include <vector>

#include <QAbstractListModel>
#include <Core/UniqueAlloc.hpp>
#include <Audio/Node.hpp>

#include "PartitionModel.hpp"

class NodeModel;

/** @brief class that contaign a list of partitionModel */
class PartitionsModel : public QAbstractListModel
{
    Q_OBJECT

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

public slots:
    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return static_cast<int>(_data->size()); }

    /** @brief Add a children to the list */
    void add(void);

    /** @brief Remove a children from the list */
    void remove(const int index);

    /** @brief Move beatrange at index */
    void move(const int from, const int to);

    /** @brief Get a single partition model */
    PartitionModel *getPartition(const int index) { return get(index); }


public: // Allow external insert / remove
    using QAbstractListModel::beginRemoveRows;
    using QAbstractListModel::endRemoveRows;
    using QAbstractListModel::beginInsertRows;
    using QAbstractListModel::endInsertRows;

private:
    Audio::Partitions *_data { nullptr };
    Core::TinyVector<Core::UniqueAlloc<PartitionModel>> _partitions;

    /** @brief Refresh internal models */
    void refreshPartitions(void);
};