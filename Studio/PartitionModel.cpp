/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionModel class
 */

#include <stdexcept>

#include <QHash>
#include <QQmlEngine>

#include "Models.hpp"
#include "PartitionsModel.hpp"

PartitionModel::PartitionModel(Audio::Partition *partition, PartitionsModel *parent) noexcept
    : QAbstractListModel(parent), _data(partition), _instances(&partition->instances(), this)
{
    connect(_instances.get(), &InstancesModel::latestInstanceChanged, [this]{
        const auto oldLast = _latestInstance;
        _latestInstance = _instances->latestInstance();
        emit latestInstanceChanged();
        parentPartitions()->processLatestInstanceChange(oldLast, _latestInstance);
    });
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PartitionModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Range),       "range" },
        { static_cast<int>(Roles::Velocity),    "velocity" },
        { static_cast<int>(Roles::Tuning),      "tuning" },
        { static_cast<int>(Roles::NoteIndex),   "noteIndex" },
        { static_cast<int>(Roles::EventType),   "eventType" },
        { static_cast<int>(Roles::Key),         "key" }
    };
}

QVariant PartitionModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("PartitionModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    const auto &child = _data->notes().at(index.row());
    switch (static_cast<Roles>(role)) {
        case Roles::Range:
            return QVariant::fromValue(reinterpret_cast<const BeatRange &>(child.range));
        case Roles::Velocity:
            return child.velocity;
        case Roles::Tuning:
            return child.tuning;
        case Roles::Key:
            return child.key;
        default:
            return QVariant();
    }
}

void PartitionModel::setName(const QString &name)
{
    Models::AddProtectedEvent(
        [this, name = Core::FlatString(name.toStdString())](void) mutable { _data->setName(std::move(name)); },
        [this, name = _data->name()] {
            if (name != _data->name())
                emit nameChanged();
        }
    );
}

void PartitionModel::setMuted(const bool muted) noexcept
{
    Models::AddProtectedEvent(
        [this, muted] {
            _data->setMuted(muted);
        },
        [this, muted = _data->muted()] {
            if (muted != _data->muted())
                emit mutedChanged();
        }
    );
}

void PartitionModel::setMidiChannels(const MidiChannels midiChannels)
{
    Models::AddProtectedEvent(
        [this, midiChannels] {
            _data->setMidiChannels(midiChannels);
        },
        [this, midiChannels = _data->midiChannels()] {
            if (midiChannels != _data->midiChannels())
                emit midiChannelsChanged();
        }
    );
}

bool PartitionModel::add(const Note &note)
{
    const auto idx = static_cast<int>(std::distance(_data->notes().begin(), _data->notes().findSortedPlacement(note)));

    return Models::AddProtectedEvent(
        [this, note] {
            _data->notes().insert(note);
        },
        [this, idx] {
            beginInsertRows(QModelIndex(), idx, idx);
            endInsertRows();
            const auto last = _data->notes().back().range.to;
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

int PartitionModel::find(const quint8 key, const quint32 beat) const noexcept
{
    int idx = 0;

    for (const auto &note : _data->notes()) {
        if (note.key != key || beat < note.range.from || beat > note.range.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

int PartitionModel::findOverlap(const Key key, const BeatRange &range) const noexcept
{
    int idx = 0;

    for (const auto &note : _data->notes()) {
        if (note.key != key || range.to < note.range.from || range.from > note.range.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

bool PartitionModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _data->notes().erase(_data->notes().begin() + idx);
        },
        [this] {
            endRemoveRows();
            const Beat last = _data->notes().empty() ? 0u : _data->notes().back().range.to;
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

const Note &PartitionModel::get(const int idx) const noexcept_ndebug
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    return reinterpret_cast<const Note &>(_data->notes().at(idx));
}

void PartitionModel::set(const int idx, const Note &range)
{
    auto newIdx = static_cast<int>(std::distance(_data->notes().begin(), _data->notes().findSortedPlacement(range)));

    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionModel::move: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    Scheduler::Get()->addEvent(
        [this, range, idx] {
            _data->notes().assign(idx, range);
        },
        [this, idx, newIdx] {
            if (idx != newIdx) {
                beginMoveRows(QModelIndex(), idx, idx, QModelIndex(), newIdx ? newIdx + 1 : 0);
                endMoveRows();
            } else {
                const auto modelIndex = index(idx);
                emit dataChanged(modelIndex, modelIndex);
                const auto last = _data->notes().back().range.to;
                if (last > _latestNote) {
                    _latestNote = last;
                    emit latestNoteChanged();
                }
            }
            emit notesChanged();
        }
    );
}

bool PartitionModel::addRange(const QVariantList &noteList)
{
    if (noteList.empty())
        return true;
    else if (noteList.size() == 1)
        return add(noteList.front().value<Note>());
    QVector<Note> notes;
    notes.reserve(noteList.size());
    for (const auto &n : noteList)
        notes.append(n.value<Note>());
    return Models::AddProtectedEvent(
        [this, notes] {
            _data->notes().insert(notes.begin(), notes.end());
        },
        [this] {
            beginResetModel();
            endResetModel();
            const auto last = _data->notes().back().range.to;
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

bool PartitionModel::removeRange(const QVariantList &indexes)
{
    if (indexes.empty())
        return true;
    else if (indexes.size() == 1)
        return remove(indexes.front().toInt());
    return Models::AddProtectedEvent(
        [this, indexes] {
            int idx = 0;
            auto it = std::remove_if(_data->notes().begin(), _data->notes().end(), [&idx, &indexes](const auto &) {
                for (const auto &i : indexes) {
                    if (i.toInt() == idx) {
                        ++idx;
                        return true;
                    }
                }
                ++idx;
                return false;
            });

            if (it != _data->notes().end())
                _data->notes().erase(it, _data->notes().end());
        },
        [this] {
            beginResetModel();
            endResetModel();
            const Beat last = _data->notes().empty() ? 0u : _data->notes().back().range.to;
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

QVariantList PartitionModel::select(const BeatRange &range, const Key keyFrom, const Key keyTo)
{
    int idx = 0;
    QVariantList indexes;

    for (const auto &note : _data->notes()) {
        if (note.key >= keyFrom && note.key <= keyTo && note.range.from <= range.to && note.range.to >= range.from)
            indexes.append(idx);
        ++idx;
    }
    return indexes;
}

void PartitionModel::updateInternal(Audio::Partition *data)
{
    if (_data == data)
        return;
    Scheduler::Get()->addEvent(
        [this, data] {
            _data = data;
            _instances->updateInternal(&_data->instances());
        },
        [this, data] {
            if (_data->notes().data() != data->notes().data()) {
                beginResetModel();
                endResetModel();
                emit notesChanged();
            }
        }
    );
}
