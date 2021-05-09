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
        { static_cast<int>(Roles::From), "from" },
        { static_cast<int>(Roles::To), "to" }
    };
}

QVariant InstancesModel::data(const QModelIndex &index, int role) const
{
    const auto &child = get(index.row());
    switch (static_cast<Roles>(role)) {
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
    const auto idx = static_cast<int>(std::distance(_data->begin(), _data->findSortedPlacement(range)));

    Scheduler::Get()->addEvent(
        [this, range] {
            _data->insert(range);
        },
        [this, idx] {
            beginInsertRows(QModelIndex(), idx, idx);
            endInsertRows();
            const auto last = _data->back().to;
            if (last > _latestInstance) {
                _latestInstance = last;
                emit latestInstanceChanged();
            }
        }
    );
}

int InstancesModel::find(const Beat beat) const noexcept
{
    int idx = 0;

    for (const auto &range : *_data) {
        if (beat < range.from || beat > range.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

int InstancesModel::findOverlap(const Beat from, const Beat to) const noexcept
{
    int idx = 0;

    for (const auto &range : *_data) {
        if (to < range.from || from > range.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

void InstancesModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("InstancesModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    Scheduler::Get()->addEvent(
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _data->erase(_data->begin() + idx);
        },
        [this] {
            endRemoveRows();
            if (!_data->empty()) {
                const auto last = _data->back().to;
                if (last > _latestInstance) {
                    _latestInstance = last;
                    emit latestInstanceChanged();
                }
            } else if (_latestInstance != 0u) {
                _latestInstance = 0;
                emit latestInstanceChanged();
            }
        }
    );
}

const BeatRange &InstancesModel::get(const int idx) const noexcept_ndebug
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("InstancesModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    return reinterpret_cast<const BeatRange &>(_data->at(idx));
}

void InstancesModel::set(const int idx, const BeatRange &range)
{
    auto newIdx = static_cast<int>(std::distance(_data->begin(), _data->findSortedPlacement(range)));

    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("InstancesModel::move: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    Scheduler::Get()->addEvent(
        [this, range, idx] {
            _data->assign(idx, range);
        },
        [this, idx, newIdx] {
            if (idx != newIdx) {
                beginMoveRows(QModelIndex(), idx, idx, QModelIndex(), newIdx ? newIdx + 1 : 0);
                endMoveRows();
            } else {
                const auto modelIndex = index(idx);
                emit dataChanged(modelIndex, modelIndex);
                const auto last = _data->back().to;
                if (last > _latestInstance) {
                    _latestInstance = last;
                    emit latestInstanceChanged();
                }
            }
        }
    );
}
