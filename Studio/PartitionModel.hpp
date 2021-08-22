/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionModel class
 */

#pragma once

#include <QAbstractListModel>

#include <Core/UniqueAlloc.hpp>
#include <Audio/Partition.hpp>

#include "Note.hpp"

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

struct NotesAnalysis
{
    Q_GADGET

    Q_PROPERTY(Beat from MEMBER from)
    Q_PROPERTY(Beat to MEMBER to)
    Q_PROPERTY(Beat distance MEMBER distance)
    Q_PROPERTY(Key min MEMBER min)
    Q_PROPERTY(Key max MEMBER max)
public:

    Beat from { 0u };
    Beat to { 0u };
    Beat distance { 0u };
    Key min { 0u };
    Key max { 0u };
};

Q_DECLARE_METATYPE(NotesAnalysis)

/** @brief Class that exposes a list of note in audio backend */
class PartitionModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
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
    explicit PartitionModel(Audio::Partition *partition, PartitionsModel *parent = nullptr, const QString &name = QString()) noexcept;

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


    /** @brief Get the name property */
    [[nodiscard]] QString name(void) const noexcept
        { return _name; }

    /** @brief Set the name property */
    void setName(const QString &name);


    /** @brief Get the current latest note */
    [[nodiscard]] Beat latestNote(void) const noexcept { return _latestNote; }


    /** @brief Get the internal audio partition */
    [[nodiscard]] Audio::Partition *audioPartition(void) noexcept { return _data; }
    [[nodiscard]] const Audio::Partition *audioPartition(void) const noexcept { return _data; }


    /** @brief Update internal data pointer if it changed */
    void updateInternal(Audio::Partition *data);

public slots:
    /** @brief Return the count of element in the model */
    int count(void) const noexcept { return static_cast<int>(_data->size()); }

    /** @brief Add node */
    bool add(const Note &note);

    /** @brief Find a note in the list using a single beat point */
    int find(const Key key, const Beat beat) const noexcept;

    /** @brief Find an exact note */
    int findExact(const Note &note) const noexcept;

    /** @brief Find a note in the list using a two beat points */
    int findOverlap(const Key key, const BeatRange &range) const noexcept;


    /** @brief Remove note at index */
    bool remove(const int index);


    /** @brief Get note at index */
    QVariant getNote(const int index) const { return QVariant::fromValue(get(index)); }

    /** @brief Get all notes */
    QVariantList getAllNotes(void) const noexcept;

    /** @brief calcul the distance between the smaller from to the latest to */
    Beat getDistance(const QVector<Note> &notes) const noexcept;
    
    /** @brief Get a list of notes using a list of indexes */
    QVector<Note> getNotes(const QVector<int> &indexes) const noexcept;


    /** @brief Set note at index */
    void set(const int idx, const Note &range);

    /** @brief Set a range of notes */
    bool setRange(const QVector<Note> &before, const QVector<Note> &after);

    /** @brief Add a group of notes */
    bool addRange(const QVector<Note> &notes);

    /** @brief Add a group of notes by a Json format */
    bool addJsonRange(const QString &json, int scale);

    /** @brief Remove a group of notes */
    bool removeRange(const QVector<int> &indexes);
    bool removeExactRange(const QVector<Note> &notes);

    /** @brief Select all notes within a specified range (returns indexes) */
    QVector<int> select(const BeatRange &range, const Key keyFrom, const Key keyTo);


    /** @brief Get an analysis of the given notes */
    NotesAnalysis getNotesAnalysis(const QVector<Note> &notes) const noexcept;

    /** @brief Overlap test in given range */
    bool hasOverlap(const NotesAnalysis &analysis) const noexcept;

signals:
    /** @brief Notify that the channel has changed */
    void nameChanged(void);

    /** @brief Notify that notes has changed */
    void notesChanged(void);

    /** @brief Notify that the latest note of the node has changed */
    void latestNoteChanged(void);

private:
    Audio::Partition *_data { nullptr };
    QString _name {};
    Beat _latestNote { 0u };

    /** @brief Perform checks after notes have changed */
    void onNotesChanged(void);
};
