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
            onInstancesChanged();
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
        if (range.to <= elem.range.from || range.from >= elem.range.to) {
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
            onInstancesChanged();
        }
    );
}

const PartitionInstance &PartitionInstancesModel::get(const int idx) const noexcept_ndebug
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionInstancesModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    return reinterpret_cast<const PartitionInstance &>(_data->at(idx));
}

QVector<PartitionInstance> PartitionInstancesModel::getInstances(const QVector<int> &indexes) const noexcept
{
    QVector<PartitionInstance> instances;

    instances.reserve(indexes.size());
    for (const auto idx : indexes) {
        instances.push_back(get(idx));
    }
    return instances;
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
            }
            onInstancesChanged();
        }
    );
}

bool PartitionInstancesModel::setRange(const QVector<PartitionInstance> &before, const QVector<PartitionInstance> &after)
{
    coreAssert(before.size() == after.size(),
        throw std::logic_error("PartitionInstancesModel::setRange: Invalid mismatch count of before / after notes"));

    QVector<int> indexes;
    QVector<PartitionInstance> res;
    indexes.reserve(before.size());
    res.reserve(indexes.size());
    for (int i = 0; i < before.size(); ++i) {
        int idx = findExact(before[i]);
        if (idx != -1) {
            indexes.push_back(idx);
            res.push_back(after[i]);
        }
    }
    if (indexes.isEmpty())
        return true;

    return Models::AddProtectedEvent(
        [this, indexes, res] {
            for (auto i = 0; i < indexes.size(); ++i)
                _data->at(static_cast<std::uint32_t>(indexes[i])) = res[i];
            _data->sort();
        },
        [this] {
            beginResetModel();
            endResetModel();
            onInstancesChanged();
        }
    );
}

bool PartitionInstancesModel::addRange(const QVector<PartitionInstance> &instances)
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
            onInstancesChanged();
        }
    );
}

bool PartitionInstancesModel::removeRange(const QVector<int> &indexes)
{
    if (indexes.empty())
        return true;
    else if (indexes.size() == 1)
        return remove(indexes.front());
    return Models::AddProtectedEvent(
        [this, indexes] {
            int idx = 0;
            auto it = std::remove_if(_data->begin(), _data->end(), [&idx, &indexes](const auto &) {
                for (const auto &i : indexes) {
                    if (i == idx) {
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
            onInstancesChanged();
        }
    );
}

bool PartitionInstancesModel::removeExactRange(const QVector<PartitionInstance> &instances)
{
    QVector<int> indexes;

    for (const auto &instance : instances) {
        int idx = findExact(instance);
        if (idx != -1)
            indexes.push_back(idx);
    }
    return removeRange(indexes);
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

PartitionInstancesAnalysis PartitionInstancesModel::getPartitionInstancesAnalysis(const QVector<PartitionInstance> &instances) const noexcept
{
    if (instances.empty())
        return PartitionInstancesAnalysis {};

    PartitionInstancesAnalysis analysis {
        /* from: */         std::numeric_limits<Beat>::max(),
        /* to: */           0u,
        /* distance: */     0u,
    };

    for (const auto &instance : instances) {
        analysis.from = std::min(analysis.from, instance.range.from);
        analysis.to = std::max(analysis.to, instance.range.to);
    }
    analysis.distance = analysis.to - analysis.from;
    return analysis;
}

bool PartitionInstancesModel::hasOverlap(const PartitionInstancesAnalysis &analysis) const noexcept
{
    return findOverlap(BeatRange(analysis.from, analysis.to)) != -1;
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

void PartitionInstancesModel::onInstancesChanged(void)
{
    const Beat last = !_data->empty() ? _data->back().range.to : 0u;

    if (last > _latestInstance) {
        _latestInstance = last;
        emit latestInstanceChanged();
    }
    emit instancesChanged();
}