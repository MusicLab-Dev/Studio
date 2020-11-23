/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionModel class
 */

#pragma once

#include <MLCore/Utils.hpp>
#include <MLAudio/Base.hpp>


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
    [[nodiscard]] int count(void) const noexcept { return  _data->size(); }
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const noexcept override noexcept_ndebug; //noexcept_ndebug remplace noexcept ou faut mettre les deux ?

    /** @brief Return true is the partition model is muted */
    [[nodiscard]] bool muted(void) const noexcept { return _muted; }

    /** @brief Set the muted propertie */
    bool setMuted(bool muted) noexcept;

    /** @brief Return the channel of the partition */
    [[nodiscard]] Channel channel(void) const noexcept { return _channel; }

    /** @brief Set the channel of the partition */
    bool setChannel(const Channel channel) noexcept;

    /** @brief Update internal data pointer if it changed */
    void updateData(Audio::BeatRanges *data) { _data = data; }

signals:
    /** @brief Notify that the muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that the channel has changed */
    void channelChanged(void);

private:
    Audio::Partition *_data { nullptr };
    UniqueAlloc<InstancesModel> _instancesModel {};

    //Properties
    bool _muted { false };
    Channel _channel {} ;
    InstancesModel *_instances { nullptr };
}