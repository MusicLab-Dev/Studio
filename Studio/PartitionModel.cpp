/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionModel class
 */

#include <stdexcept>

#include <QHash>
#include <QQmlEngine>

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
    if (this->muted() == muted)
        return false;
    _data->setMuted(muted);
    emit mutedChanged();
    return true;
}

bool PartitionModel::setChannel(const Channel channel) noexcept
{
    if (_channel == channel)
        return false;
    _channel = channel;
    emit channelChanged();
    return true;
}

void PartitionModel::addNote(const Audio::Note &note) noexcept
{
    _data->notes().push(note);
}

void PartitionModel::removeNote(const int index) noexcept
{
    auto it = _data->notes().begin() + index;
    _data->notes().erase(it);
}

void PartitionModel::updateInternal(Audio::Partition *data)
{
    if (_data == data)
        return;
    std::swap(_data, data);
    if (_data->notes().data() != data->notes().data()) {
        beginResetModel();
        endResetModel();
    }
    _instances->updateInternal(&_data->instances());
}