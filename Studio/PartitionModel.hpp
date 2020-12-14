/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionModel class
 */

#pragma once

#include <QAbstractListModel>

#include <Core/Utils.hpp>
#include <Core/UniqueAlloc.hpp>
#include <Audio/Partition.hpp>
#include <Audio/Base.hpp>

#include "InstancesModel.hpp"


/** @brief Class that exposes a list of note in audio backend */
class PartitionModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(Channel channel READ channel WRITE setChannel NOTIFY channelChanged)

public:
    /** @brief Roles of each partition */
    enum class Roles {
        Range = Qt::UserRole + 1,
        Velocity,
        Tuning,
        NoteIndex,
        EventType,
        Key
    };

    /** @brief Default constructor */
    explicit PartitionModel(QObject *parent = nullptr) noexcept;

    /** @brief Destruct the Partition */
    ~PartitionModel(void) noexcept = default;

    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int count(void) const noexcept { return  _data->count(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;

    /** @brief Return true is the partition model is muted */
    [[nodiscard]] bool muted(void) const noexcept { return _muted; }

    /** @brief Set the muted propertie */
    bool setMuted(bool muted) noexcept;
#pragma once

    /** @brief Return the channel of the partition */
    [[nodiscard]] Audio::Channel channel(void) const noexcept { return _channel; }

    /** @brief Set the channel of the partition */
    bool setChannel(const Audio::Channel channel) noexcept;

    /** @brief Update internal data pointer if it changed */
    void updateData(Audio::Partition *data) { _data = data; }

signals:
    /** @brief Notify that the muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that the channel has changed */
    void channelChanged(void);

private:
    Audio::Partition *_data { nullptr };
    Core::UniqueAlloc<InstancesModel> _instancesModel {};

    //Properties
    bool _muted { false };
    Audio::Channel _channel {} ;
    InstancesModel *_instances { nullptr };
};