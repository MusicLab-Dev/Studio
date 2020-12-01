/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionModel class
 */

#include <stdexcept>

#include "PartitionModel.hpp"

PartitionModel::PartitionModel(QObject *parent) noexcept
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PartitionModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { Roles::Range, "range"},
        { Roles::Velocity, "velocity"},
        { Roles::Tuning, "tuning"},
        { Roles::NoteIndex, "noteIndex"},
        { Roles::EventType, "eventType"},
        { Roles::Key, "key"}
    };
}

QVariant PartitionModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() < 0 || index.row() >= count(),
        throw std::range_error("PartitionModel::data: Given index is not in range"));
    const auto &child = (*_data)[index.row()];
    switch (role) {
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
    if (muted == _muted)
        return false;
    _muted = muted;
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

void PartitionModel::updateIternal(Audio::Automation *data)
{
    if (_data == data)
        return;
    _data = data;
    // Check if the underlying instances have different data pointer than new one
    if (data->instances().data() != _instancesModel->getInternal()->data()) {
        beginResetModel();
        _instancesModel.updateInternal(&_data->instances());
        endResetModel();
    }
}