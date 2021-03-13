/**
 * @ Author: Dorian Gonzalez
 * @ Description: InsatancesModel class
 */

#include <stdexcept>

#include <QHash>

#include "Scheduler.hpp"
#include "InstancesModel.hpp"

InstancesModel::InstancesModel(Audio::BeatRanges *beatRanges, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(beatRanges)
{
}

QHash<int, QByteArray> InstancesModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { Roles::From, "from" },
        { Roles::To, "to" }
    };
}

QVariant InstancesModel::data(const QModelIndex &index, int role) const
{
    const auto &child = get(index.row());
    switch (role) {
    case Roles::From:
        return child.from;
    case Roles::To:
        return child.to;
    default:
        return QVariant();
    }
}

void InstancesModel::updateInternal(Audio::BeatRanges *data)
{
    if (_data == data)
        return;
    beginResetModel();
    _data = data;
    endResetModel();
}

const Audio::BeatRange &InstancesModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("InstancesModel::get: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    return (*_data)[static_cast<unsigned long>(index)];
}

void InstancesModel::add(const Audio::BeatRange &range) noexcept
{
    Scheduler::Get()->addEvent(
        [this, range] {
            _data->push(range);
        },
        [this] {
            beginResetModel();
            endResetModel();
        }
    );
}

void InstancesModel::remove(const int index) noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("InstancesModel::remove: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    Scheduler::Get()->addEvent(
        [this, index] {
            _data->erase(_data->begin() + index);
        },
        [this, index] {
            beginRemoveRows(QModelIndex(), index, index);
            endRemoveRows();
        }
    );
}

void InstancesModel::move(const int index, const Audio::BeatRange &range) noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("InstancesModel::move: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    Scheduler::Get()->addEvent(
        [this, index, range] {
            _data->at(static_cast<unsigned long>(index)) = range;
            //_data->sort();
        },
        [this, index] {
            beginRemoveRows(QModelIndex(), index, index);
            endRemoveRows();
        }
    );
}
