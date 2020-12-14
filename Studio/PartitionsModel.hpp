/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionsModel class
 */

#pragma once

#include "PartitionModel.hpp"

#include <vector>

#include <MLCore/Utils.hpp>
#include <MLAudio/Base.hpp>


/** @brief class that contaign a list of partitionModel */
class PartitionsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    /** @brief Roles of each instance */
    enum class Roles {
        Partition = Qt::UserRole + 1
    };

    /** @brief Default constructor */
    explicit PartitionsModel(QObject *parent = nullptr) noexcept;

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
    [[nodiscard]] const PartitionModel &get(const int index) const;

public slots:
    /** @brief Remove a children from the list */
    void remove(const int index);

    /** @brief Move beatrange at index */
    void move(const int from, const int to);

public /* slots */:
    /** @brief Add a children to the list */
    Q_INVOKABLE void add(const Audio::BeatRange &range) noexcept_ndebug;


private:
    Audio::Partitions *_data { nullptr };
    std::vector<UniqueAlloc<PartitionModel>> _models {};
}