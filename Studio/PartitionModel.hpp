/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionModel class
 */

#pragma once

#include <QAbstractListModel>

#include <Core/UniqueAlloc.hpp>
#include <Audio/Partition.hpp>

#include "Note.hpp"
#include "InstancesModel.hpp"

class PartitionModel;

struct PartitionWrapper
{
    Q_GADGET

    Q_PROPERTY(PartitionModel *instance MEMBER instance)
public:

    PartitionModel *instance { nullptr };
};

Q_DECLARE_METATYPE(PartitionWrapper)

/** @brief Class that exposes a list of note in audio backend */
class PartitionModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool muted READ muted WRITE setMuted NOTIFY mutedChanged)
    Q_PROPERTY(MidiChannels midiChannels READ midiChannels WRITE setMidiChannels NOTIFY midiChannelsChanged)
    Q_PROPERTY(InstancesModel *instances READ getInstances NOTIFY instancesChanged)

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

    /** @brief Virtual destructor */
    ~PartitionModel(void) noexcept override = default;


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;


    /** @brief Get note at index */
    [[nodiscard]] const Note &get(const int idx) const noexcept_ndebug;


    /** @brief Get the list of instances */
    [[nodiscard]] InstancesModel &instances(void) noexcept { return *_instances; }
    [[nodiscard]] const InstancesModel &instances(void) const noexcept { return *_instances; }
    [[nodiscard]] InstancesModel *getInstances(void) noexcept { return _instances.get(); }


    /** @brief Get the name property */
    [[nodiscard]] QString name(void) const noexcept
        { return QString::fromLocal8Bit(_data->name().data(), _data->name().size()); }

    /** @brief Set the name property */
    void setName(const QString &name);


    /** @brief Return true is the partition model is muted */
    [[nodiscard]] bool muted(void) const noexcept { return _data->muted(); }

    /** @brief Set the muted propertie */
    void setMuted(bool muted) noexcept;


    /** @brief Return the channel of the partition */
    [[nodiscard]] MidiChannels midiChannels(void) const noexcept { return static_cast<MidiChannels>(_data->midiChannels()); }

    /** @brief Set the channel of the partition */
    void setMidiChannels(const MidiChannels midiChannels);


    /** @brief Update internal data pointer if it changed */
    void updateInternal(Audio::Partition *data);

public slots:
    /** @brief Return the count of element in the model */
    int count(void) const noexcept { return static_cast<int>(_data->notes().size()); }

    /** @brief Add node */
    void add(const Note &note);

    /** @brief Remove note at index */
    void remove(const int index);

    /** @brief Get note at index */
    QVariant getNote(const int index) const { return QVariant::fromValue(get(index)); }

    /** @brief Set note at index */
    void set(const int idx, const Note &range);

signals:
    /** @brief Notify that the channel has changed */
    void nameChanged(void);

    /** @brief Notify that the muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that the channel has changed */
    void midiChannelsChanged(void);

    /** @brief Notify that the instances model has changed */
    void instancesChanged(void);

private:
    Audio::Partition *_data { nullptr };
    Core::UniqueAlloc<InstancesModel> _instances {};
};