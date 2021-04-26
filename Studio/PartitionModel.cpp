/**
 * @ Author: Dorian Gonzalez
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

bool PartitionModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, idx] {
            _data->notes().erase(_data->notes().begin() + idx);
        },
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            endRemoveRows();
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
            }
        }
    );
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
            }
        });
}