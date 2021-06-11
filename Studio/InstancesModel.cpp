/**
 * @ Author: Dorian Gonzalez
 * @ Description: InsatancesModel class
 */

#include <stdexcept>

#include <QHash>

#include "Models.hpp"
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

bool InstancesModel::add(const BeatRange &range)
{
    const auto idx = static_cast<int>(std::distance(_data->begin(), _data->findSortedPlacement(range)));

    return Models::AddProtectedEvent(
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

int InstancesModel::findOverlap(const BeatRange &range) const noexcept
{
    int idx = 0;

    for (const auto &instance : *_data) {
        if (range.to < instance.from || instance.from > instance.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

bool InstancesModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("InstancesModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
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

bool InstancesModel::addRange(const QVariantList &instanceList)
{
    if (instanceList.empty())
        return true;
    else if (instanceList.size() == 1)
        return add(instanceList.front().value<BeatRange>());
    QVector<BeatRange> instances;
    instances.reserve(instanceList.size());
    for (const auto &instance : instanceList)
        instances.append(instance.value<BeatRange>());
    return Models::AddProtectedEvent(
        [this, instances] {
            _data->insert(instances.begin(), instances.end());
        },
        [this] {
            beginResetModel();
            endResetModel();
            const auto last = _data->back().to;
            if (last > _latestInstance) {
                _latestInstance = last;
                emit latestInstanceChanged();
            }
        }
    );
}

bool InstancesModel::removeRange(const QVariantList &indexes)
{
    if (indexes.empty())
        return true;
    else if (indexes.size() == 1)
        return remove(indexes.front().toInt());
    return Models::AddProtectedEvent(
        [this, indexes] {
            int idx = 0;
            auto it = std::remove_if(_data->begin(), _data->end(), [&idx, &indexes](const auto &) {
                for (const auto &i : indexes) {
                    if (i.toInt() == idx) {
                        ++idx;
                        return true;
                    }
                }
                ++idx;
                return false;
            });

            if (it != _data->end())
                _data->erase(it, _data->end());
        },
        [this] {
            beginResetModel();
            endResetModel();
            const Beat last = _data->empty() ? 0u : _data->back().to;
            if (last > _latestInstance) {
                _latestInstance = last;
                emit latestInstanceChanged();
            }
        }
    );
}

QVariantList InstancesModel::select(const BeatRange &range)
{
    int idx = 0;
    QVariantList indexes;

    for (const auto &instance : *_data) {
        if (instance.from <= range.to && instance.to >= range.from)
            indexes.append(idx);
        ++idx;
    }
    return indexes;
}

QVariantList InstancesModel::getInstances(void) const
{
    QVariantList list;
    for (int i = 0; i < count(); i++)
        list.append(QVariant::fromValue(get(i)));
    return list;
}