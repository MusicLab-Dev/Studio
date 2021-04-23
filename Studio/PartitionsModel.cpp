/**
 * @ Author: Dorian Gonzalez
 * @ Description: PartitionsModel class
 */

#include <stdexcept>
#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "NodeModel.hpp"

PartitionsModel::PartitionsModel(Audio::Partitions *partitions, NodeModel *parent) noexcept
    : QAbstractListModel(parent), _data(partitions)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PartitionsModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Partition), "partitionInstance" }
    };
}

QVariant PartitionsModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("PartitionsModel::get: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    switch (static_cast<PartitionsModel::Roles>(role)) {
    case Roles::Partition:
        return QVariant::fromValue(PartitionWrapper { const_cast<PartitionModel *>(get(index.row())) });
    default:
        return QVariant();
    }
}

const PartitionModel *PartitionsModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("PartitionsModel::get: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    return _partitions.at(index).get();
}

bool PartitionsModel::add(void)
{
    // Get a unique name for this partition
    std::string name = [this] {
        std::string name;
        auto size = _partitions.size();
        while (true) {
            bool unique = true;
            name = "Partition " + std::to_string(size);
            for (auto &partition : *_data) {
                if (partition.name() == name) {
                    unique = false;
                    break;
                }
            }
            if (unique)
                break;
            ++size;
        }
        return name;
    }();

    return Models::AddProtectedEvent(
        [this, name = Core::FlatString(std::move(name))](void) mutable {
            _data->push().setName(std::move(name));
        },
        [this] {
            const auto partitionsData = _partitions.data();
            const auto idx = _partitions.size();
            beginInsertRows(QModelIndex(), idx, idx);
            _partitions.push(&_data->at(idx), this);
            endInsertRows();
            if (_partitions.data() != partitionsData)
                refreshPartitions();
        }
    );
}

bool PartitionsModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("ControlsModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, idx] {
            _data->erase(_data->begin() + idx);
        },
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _partitions.erase(_partitions.begin() + idx);
            endRemoveRows();
            const auto count = _partitions.size();
            for (auto i = static_cast<std::size_t>(idx); i < count; ++i)
                _partitions.at(i)->updateInternal(&_data->at(i));
        }
    );
}

bool PartitionsModel::move(const int from, const int to)
{
    if (from == to)
        return false;
    coreAssert(from >= 0 && from < count() && to >= 0 && to < count(),
        throw std::range_error("ControlModel::move: Given index is not in range: [" + std::to_string(from) + ", " + std::to_string(to) + "[ out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, from, to] {
            _data->move(from, from, to);
        },
        [this, from, to] {
            beginMoveRows(QModelIndex(), from, from, QModelIndex(), to ? to + 1 : 0);
            _partitions.move(from, from, to);
            endMoveRows();
            _partitions.at(from)->updateInternal(&_data->at(from));
            _partitions.at(to)->updateInternal(&_data->at(to));
        }
    );
}

void PartitionsModel::addOnTheFly(const NoteEvent &note, NodeModel *node, const quint32 partitionIndex)
{
    Scheduler::Get()->addEvent(
        [this, note] {
            _data->headerCustomType().push(note);
        },
        [this, node, partitionIndex] {
            const auto scheduler = Scheduler::Get();
            if (!scheduler->running()) {
                scheduler->playPartition(Scheduler::PlaybackMode::OnTheFly, node, partitionIndex, 0);
            }
        }
    );
}

void PartitionsModel::refreshPartitions(void)
{
    Models::RefreshModels(this, _partitions, *_data, this);
}