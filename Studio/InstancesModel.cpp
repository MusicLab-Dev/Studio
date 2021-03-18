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

void InstancesModel::add(const BeatRange &range)
{
    const auto idx = std::distance(_data->begin(), _data->findSortedPlacement(range));

    Scheduler::Get()->addEvent(
        [this, range] {
            _data->insert(range);
        },
        [this, idx] {
            beginInsertRows(QModelIndex(), idx, idx);
            endInsertRows();
        }
    );
}

void InstancesModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("InstancesModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    Scheduler::Get()->addEvent(
        [this, idx] {
            _data->erase(_data->begin() + idx);
        },
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            endRemoveRows();
        }
    );
}

const BeatRange &InstancesModel::get(const int idx) const
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("InstancesModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    return reinterpret_cast<const BeatRange &>(_data->at(idx));
}

void InstancesModel::set(const int idx, const BeatRange &range)
{
    auto newIdx = std::distance(_data->begin(), _data->findSortedPlacement(range));

    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("InstancesModel::move: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    Scheduler::Get()->addEvent(
        [this, range, idx] {
            _data->assign(idx, range);
        },
        [this, idx, newIdx] {
            if (idx != newIdx) {
                beginMoveRows(QModelIndex(), idx, idx, QModelIndex(), newIdx + 1);
                endMoveRows();
            } else {
                const auto modelIndex = index(idx);
                emit dataChanged(modelIndex, modelIndex);
            }
        }
    );
}
