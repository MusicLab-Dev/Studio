/**
 * @ Author: Cédric Lucchese
 * @ Description: InsatancesModel class
 */

#pragma once

#include <QAbstractListModel>

#include "PartitionInstance.hpp"

class PartitionsModel;

/** @brief The studio is the instance running the application process */
class PartitionInstancesModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(Beat latestInstance READ latestInstance NOTIFY latestInstanceChanged)

public:
    /** @brief Roles of each instance */
    enum class Roles {
        PartitionIndex = Qt::UserRole + 1,
        Offset,
        Range
    };

    /** @brief Default constructor */
    explicit PartitionInstancesModel(Audio::PartitionInstances *instances, QObject *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~PartitionInstancesModel(void) noexcept override = default;


    /** @brief Get the parent partitions if it exists */
    [[nodiscard]] PartitionsModel *parentPartitions(void) noexcept
        { return reinterpret_cast<PartitionsModel *>(parent()); }


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  static_cast<int>(_data->size()); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;


    /** @brief Get the current latest instance */
    [[nodiscard]] Beat latestInstance(void) const noexcept { return _latestInstance; }


    /** @brief Get instance at index */
    [[nodiscard]] const PartitionInstance &get(const int idx) const noexcept_ndebug;

    /** @brief Update internal data pointer if it changed */
    void updateInternal(Audio::PartitionInstances *data);

    /** @brief Get the audio instances */
    [[nodiscard]] Audio::PartitionInstances *audioInstances(void) noexcept { return _data; }
    [[nodiscard]] const Audio::PartitionInstances *audioInstances(void) const noexcept { return _data; }

public slots:
    /** @brief Add instance */
    bool add(const PartitionInstance &instance);

    /** @brief Find an instance in the list using a single beat point */
    int find(const Beat beat) const noexcept;

    /** @brief Find an instance in the list using a single beat point */
    int findExact(const PartitionInstance &instance) const noexcept;

    /** @brief Find an instance in the list using a two beat points */
    int findOverlap(const BeatRange &range) const noexcept;

    /** @brief Remove instance at index */
    bool remove(const int index);

    /** @brief Get instance at index */
    QVariant getInstance(const int index) const { return QVariant::fromValue(get(index)); }

    /** @brief Set instance at index */
    void set(const int index, const PartitionInstance &instance);

    /** @brief Add a group of instances */
    bool addRange(const QVariantList &instances);
    bool addRealRange(const QVector<PartitionInstance> &instances);

    /** @brief Remove a group of instances */
    bool removeRange(const QVariantList &indexes);

    /** @brief Select all notes within a specified range (returns indexes) */
    QVariantList select(const BeatRange &range);

    /** @brief Remove all instances of a given partition, doesn't update model (thread unsafe) */
    void partitionRemovedUnsafe(const std::uint32_t partitionIndex);

    /** @brief Notification that a partition has been removed */
    void partitionRemovedNotify(void);

signals:
    /** @brief Notify that the latest instance of the list has changed */
    void latestInstanceChanged(void);

    /** @brief Notify that internal instances has changed */
    void instancesChanged(void);

private:
    Audio::PartitionInstances *_data { nullptr };
    Beat _latestInstance { 0u };
};
