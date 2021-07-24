/**
 * @ Author: Cédric Lucchese
 * @ Description: InsatancesModel class
 */

#include <stdexcept>

#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "PartitionInstancesModel.hpp"

PartitionInstancesModel::PartitionInstancesModel(Audio::PartitionInstances *data, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(data)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PartitionInstancesModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::PartitionIndex), "partitionIndex" },
        { static_cast<int>(Roles::Offset), "offset" },
        { static_cast<int>(Roles::Range), "range" }
    };
}

QVariant PartitionInstancesModel::data(const QModelIndex &index, int role) const
{
    const auto &child = get(index.row());
    switch (static_cast<Roles>(role)) {
    case Roles::PartitionIndex:
        return child.partitionIndex;
    case Roles::Offset:
        return child.offset;
    case Roles::Range:
        return QVariant::fromValue(BeatRange(child.range));
    default:
        return QVariant();
    }
}

void PartitionInstancesModel::updateInternal(Audio::PartitionInstances *data)
{
    if (_data == data)
        return;
    beginResetModel();
    _data = data;
    endResetModel();
}

bool PartitionInstancesModel::add(const PartitionInstance &instance)
{
    const auto placement = _data->findSortedPlacement(instance);
    const auto idx = static_cast<int>(std::distance(_data->begin(), placement));

    return Models::AddProtectedEvent(
        [this, instance, placement] {
            _data->insertAt(placement, instance);
        },
        [this, idx] {
            beginInsertRows(QModelIndex(), idx, idx);
            endInsertRows();
            const auto last = _data->back().range.to;
            if (last > _latestInstance) {
                _latestInstance = last;
                emit latestInstanceChanged();
            }
            emit instancesChanged();
        }
    );
}

int PartitionInstancesModel::find(const Beat beat) const noexcept
{
    int idx = 0;

    for (const auto &instance : *_data) {
        if (beat < instance.range.from || beat > instance.range.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

int PartitionInstancesModel::findExact(const PartitionInstance &instance) const noexcept
{
    int idx = 0;

    for (const auto &inst : *_data) {
        if (inst == instance)
            return idx;
        ++idx;
    }
    return -1;
}

int PartitionInstancesModel::findOverlap(const BeatRange &range) const noexcept
{
    int idx = 0;

    for (const auto &elem : *_data) {
        if (range.to < elem.range.from || range.from > elem.range.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

bool PartitionInstancesModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionInstancesModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _data->erase(_data->begin() + idx);
        },
        [this] {
            endRemoveRows();
            if (!_data->empty()) {
                const auto last = _data->back().range.to;
                if (last > _latestInstance) {
                    _latestInstance = last;
                    emit latestInstanceChanged();
                }
            } else if (_latestInstance != 0u) {
                _latestInstance = 0u;
                emit latestInstanceChanged();
            }
            emit instancesChanged();
        }
    );
}

const PartitionInstance &PartitionInstancesModel::get(const int idx) const noexcept_ndebug
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionInstancesModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    return reinterpret_cast<const PartitionInstance &>(_data->at(idx));
}

void PartitionInstancesModel::set(const int idx, const PartitionInstance &instance)
{
    auto newIdx = static_cast<int>(std::distance(_data->begin(), _data->findSortedPlacement(instance)));

    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionInstancesModel::move: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    Scheduler::Get()->addEvent(
        [this, instance, idx] {
            _data->assign(idx, instance);
        },
        [this, idx, newIdx] {
            if (idx != newIdx) {
                beginMoveRows(QModelIndex(), idx, idx, QModelIndex(), newIdx ? newIdx + 1 : 0);
                endMoveRows();
            } else {
                const auto modelIndex = index(idx);
                emit dataChanged(modelIndex, modelIndex);
                const auto last = _data->back().range.to;
                if (last > _latestInstance) {
                    _latestInstance = last;
                    emit latestInstanceChanged();
                }
            }
            emit instancesChanged();
        }
    );
}

bool PartitionInstancesModel::addRange(const QVariantList &instanceList)
{
    if (instanceList.empty())
        return true;
    else if (instanceList.size() == 1)
        return add(instanceList.front().value<PartitionInstance>());
    QVector<PartitionInstance> instances;
    instances.reserve(instanceList.size());
    for (const auto &instance : instanceList)
        instances.append(instance.value<PartitionInstance>());
    return Models::AddProtectedEvent(
        [this, instances] {
            _data->insert(instances.begin(), instances.end());
        },
        [this] {
            beginResetModel();
            endResetModel();
            const auto last = _data->back().range.to;
            if (last > _latestInstance) {
                _latestInstance = last;
                emit latestInstanceChanged();
            }
            emit instancesChanged();
        }
    );
}

bool PartitionInstancesModel::addRealRange(const QVector<PartitionInstance> &instances)
{
    if (instances.empty())
        return true;
    else if (instances.size() == 1)
        return add(instances.front());
    return Models::AddProtectedEvent(
        [this, instances] {
            _data->insert(instances.begin(), instances.end());
        },
        [this] {
            beginResetModel();
            endResetModel();
            const auto last = _data->back().range.to;
            if (last > _latestInstance) {
                _latestInstance = last;
                emit latestInstanceChanged();
            }
            emit instancesChanged();
        }
    );
}

bool PartitionInstancesModel::removeRange(const QVariantList &indexes)
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
            const Beat last = _data->empty() ? 0u : _data->back().range.to;
            if (last > _latestInstance) {
                _latestInstance = last;
                emit latestInstanceChanged();
            }
            emit instancesChanged();
        }
    );
}

QVariantList PartitionInstancesModel::select(const BeatRange &range)
{
    int idx = 0;
    QVariantList indexes;

    for (const auto &elem : *_data) {
        if (elem.range.from <= range.to && elem.range.to >= range.from)
            indexes.append(idx);
        ++idx;
    }
    return indexes;
}

void PartitionInstancesModel::partitionRemovedUnsafe(const std::uint32_t partitionIndex)
{
    auto it = std::remove_if(_data->begin(), _data->end(), [partitionIndex](auto &instance) {
        if (instance.partitionIndex > partitionIndex) {
            --instance.partitionIndex;
            return false;
        } else
            return instance.partitionIndex == partitionIndex;
    });

    if (it != _data->end())
        _data->erase(it, _data->end());
}

void PartitionInstancesModel::partitionRemovedNotify(void)
{
    beginResetModel();
    endResetModel();
    emit instancesChanged();
}
