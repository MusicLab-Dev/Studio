/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionsModel class
 */

#pragma once

#include <vector>

#include <QAbstractListModel>
#include <Core/UniqueAlloc.hpp>
#include <Core/Utils.hpp>
#include <Audio/Base.hpp>
#include <Audio/Node.hpp>

#include "PartitionModel.hpp"

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
    explicit PartitionsModel(Audio::Partitions *partitions, QObject *parent = nullptr) noexcept;

    /** @brief Destruct the Partitions */
    ~PartitionsModel(void) noexcept = default;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  _data->size(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Get a beat range from internal list */
    [[nodiscard]] const PartitionModel *get(const int index) const;

public slots:
    /** @brief Add a children to the list */
    void add(void);

    /** @brief Remove a children from the list */
    void remove(const int index);

    /** @brief Move beatrange at index */
    void move(const int from, const int to);

private:
    Audio::Partitions *_data { nullptr };
    Core::Vector<Core::UniqueAlloc<PartitionModel>> _partitions;

    /** @brief Refresh internal models */
    void refreshControls(void);
};