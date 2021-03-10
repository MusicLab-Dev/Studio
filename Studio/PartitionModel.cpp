/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionModel class
 */

#include <stdexcept>

#include <QHash>
#include <QQmlEngine>

#include "Scheduler.hpp"
#include "PartitionModel.hpp"

PartitionModel::PartitionModel(Audio::Partition *partition, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(partition), _instances(&partition->instances(), this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PartitionModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Range), "range"},
        { static_cast<int>(Roles::Velocity), "velocity"},
        { static_cast<int>(Roles::Tuning), "tuning"},
        { static_cast<int>(Roles::NoteIndex), "noteIndex"},
        { static_cast<int>(Roles::EventType), "eventType"},
        { static_cast<int>(Roles::Key), "key"}
    };
}

QVariant PartitionModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() < 0 || index.row() >= count(),
        throw std::range_error("PartitionModel::data: Given index is not in range"));
    //const auto &child = (*_data)[index.row()];
    switch (static_cast<Roles>(role)) {
        case Roles::Range:
        case Roles::Velocity:
        case Roles::Tuning:
        case Roles::NoteIndex:
        case Roles::EventType:
        case Roles::Key:
            return QVariant();
        default:
            return QVariant();
    }
}

bool PartitionModel::setMuted(const bool muted) noexcept
{
    if (!_data->setMuted(muted))
        return false;
    emit mutedChanged();
    return true;
}

bool PartitionModel::setMidiChannels(const MidiChannels channel) noexcept
{
    if (!_data->setMidiChannels(channel))
        return false;
    emit midiChannelsChanged();
    return true;
}

void PartitionModel::addNote(const Audio::Note &note) noexcept
{
    Scheduler::Get()->addEvent(
        [this, &note] {
            _data->notes().push(note);
        });
}

void PartitionModel::removeNote(const int index) noexcept
{
    Scheduler::Get()->addEvent(
        [this, &index] {
            auto it = _data->notes().begin() + index;
            _data->notes().erase(it);
        });
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