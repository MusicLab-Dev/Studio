/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionModel class
 */

#pragma once

#include <QAbstractListModel>

#include <Core/UniqueAlloc.hpp>
#include <Audio/Partition.hpp>

#include "Note.hpp"
#include "InstancesModel.hpp"

class PartitionModel;
class PartitionsModel;

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
    Q_PROPERTY(Beat latestInstance READ latestInstance NOTIFY latestInstanceChanged)
    Q_PROPERTY(Beat latestNote READ latestNote NOTIFY latestNoteChanged)

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
    explicit PartitionModel(Audio::Partition *partition, PartitionsModel *parent = nullptr) noexcept;

    /** @brief Virtual destructor */
    ~PartitionModel(void) noexcept override = default;

    /** @brief Get the parent partitions if it exists */
    [[nodiscard]] PartitionsModel *parentPartitions(void) noexcept
        { return reinterpret_cast<PartitionsModel *>(parent()); }


    /** @brief Get the list of all roles */
    [[nodiscard]] QHash<int, QByteArray> roleNames(void) const noexcept override;

    /** @brief Return the count of element in the model */
    [[nodiscard]] int rowCount(const QModelIndex &) const noexcept override { return count(); }

    /** @brief Query a role from children */
    [[nodiscard]] QVariant data(const QModelIndex &index, int role) const override;


    /** @brief Get note at index */
    [[nodiscard]] const Note &get(const int idx) const noexcept_ndebug;
    [[nodiscard]] Note &get(const int idx) noexcept_ndebug
        { return const_cast<Note &>(const_cast<const PartitionModel *>(this)->get(idx)); }


    /** @brief Get the list of instances */
    [[nodiscard]] InstancesModel &instances(void) noexcept { return *_instances; }
    [[nodiscard]] const InstancesModel &instances(void) const noexcept { return *_instances; }
    [[nodiscard]] InstancesModel *getInstances(void) noexcept { return _instances.get(); }


    /** @brief Get the name property */
    [[nodiscard]] QString name(void) const noexcept
        { return QString::fromLocal8Bit(_data->name().data(), static_cast<int>(_data->name().size())); }

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


    /** @brief Get the current latest instance */
    [[nodiscard]] Beat latestInstance(void) const noexcept { return _latestInstance; }

    /** @brief Get the current latest note */
    [[nodiscard]] Beat latestNote(void) const noexcept { return _latestNote; }


    /** @brief Get the internal audio partition */
    [[nodiscard]] Audio::Partition *audioPartition(void) noexcept { return _data; }
    [[nodiscard]] const Audio::Partition *audioPartition(void) const noexcept { return _data; }


    /** @brief Update internal data pointer if it changed */
    void updateInternal(Audio::Partition *data);

public slots:
    /** @brief Return the count of element in the model */
    int count(void) const noexcept { return static_cast<int>(_data->notes().size()); }

    /** @brief Add node */
    bool add(const Note &note);

    /** @brief Find a note in the list using a single beat point */
    int find(const Key key, const Beat beat) const noexcept;

    /** @brief Find a note in the list using a two beat points */
    int findOverlap(const Key key, const BeatRange &range) const noexcept;

    /** @brief Remove note at index */
    bool remove(const int index);

    /** @brief Get note at index */
    QVariant getNote(const int index) const { return QVariant::fromValue(get(index)); }

    /** @brief Set note at index */
    void set(const int idx, const Note &range);

    /** @brief Add a group of notes */
    bool addRange(const QVariantList &notes);

    /** @brief Remove a group of notes */
    bool removeRange(const QVariantList &indexes);

    /** @brief Select all notes within a specified range (returns indexes) */
    QVariantList select(const BeatRange &range, const Key keyFrom, const Key keyTo);

signals:
    /** @brief Notify that the channel has changed */
    void nameChanged(void);

    /** @brief Notify that the muted property has changed */
    void mutedChanged(void);

    /** @brief Notify that the channel has changed */
    void midiChannelsChanged(void);

    /** @brief Notify that the instances model has changed */
    void instancesChanged(void);

    /** @brief Notify that notes has changed */
    void notesChanged(void);

    /** @brief Notify that the latest instance of the partition has changed */
    void latestInstanceChanged(void);

    /** @brief Notify that the latest note of the node has changed */
    void latestNoteChanged(void);

private:
    Audio::Partition *_data { nullptr };
    Core::UniqueAlloc<InstancesModel> _instances {};
    Beat _latestInstance { 0u };
    Beat _latestNote { 0u };
};