/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionModel class
 */

#pragma once

#include <QObject>
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
    Q_PROPERTY(MidiChannels midiChannels READ midiChannels WRITE setMidiChannels NOTIFY midiChannelsChanged)

public:
    /** @brief Roles of each partition */
    enum class Roles : int {
        Range = Qt::UserRole + 1,
        Velocity,
        Tuning,
        NoteIndex,
        EventType,
        Key
    };

    /** @brief Midi channels bitset */
    using MidiChannels = Audio::MidiChannels;


    /** @brief Default constructor */
    explicit PartitionModel(Audio::Partition *partition, QObject *parent = nullptr) noexcept;

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
    [[nodiscard]] bool muted(void) const noexcept { return _data->muted(); }

    /** @brief Set the muted propertie */
    bool setMuted(bool muted) noexcept;

    /** @brief Return the channel of the partition */
    [[nodiscard]] MidiChannels midiChannels(void) const noexcept { return static_cast<MidiChannels>(_data->midiChannels()); }

    /** @brief Set the channel of the partition */
    bool setMidiChannels(const MidiChannels channel) noexcept;

    /** @brief Get the instances */
    [[nodiscard]] InstancesModel &instances(void) noexcept { return *_instances; }
    [[nodiscard]] const InstancesModel &instances(void) const noexcept { return *_instances; }


    /** @brief Update internal data pointer if it changed */
    void updateInternal(Audio::Partition *data);

public slots:
    /** @brief Add note */
    void addNote(const Audio::Note &note) noexcept;

    /** @brief Remove note at the index */
    void removeNote(const int index) noexcept;

signals:
    /** @brief Notify that the muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that the channel has changed */
    void midiChannelsChanged(void);

private:
    Audio::Partition *_data { nullptr };
    Core::UniqueAlloc<InstancesModel> _instances {};
};