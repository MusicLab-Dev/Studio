/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionsModel class
 */

#include <stdexcept>
#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "PartitionsModel.hpp"

PartitionsModel::PartitionsModel(Audio::Partitions *partitions, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(partitions)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PartitionsModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Partition), "partition" }
    };
}

QVariant PartitionsModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() < 0 || index.row() >= count(),
        throw std::range_error("PartitionsModel::data: Given index is not in range"));
    switch (static_cast<PartitionsModel::Roles>(role)) {
    case Roles::Partition:
        return get(index.row());
    default:
        return QVariant();
    }
}

const PartitionModel *PartitionsModel::get(const int index) const
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("PartitionsModel::get: Given index is not in range"));
    return _partitions.at(index).get();
}

void PartitionsModel::add(const Audio::BeatRange &range) noexcept_ndebug
{
    beginInsertRows(QModelIndex(), count(), count());
    _data->push();
    refreshControls();
    endInsertRows();
}

void PartitionsModel::remove(const int index)
{
    beginResetModel();
    _data->erase(_data->begin() + index);
    _partitions.erase(_partitions.begin() + index);
    refreshControls();
    endResetModel();
}

void PartitionsModel::move(const int from, const int to)
{
    /** TODO */
}

void PartitionsModel::refreshControls(void)
{
    Models::RefreshModels(_partitions, *_data, this);
}