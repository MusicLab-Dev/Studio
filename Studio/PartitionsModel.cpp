/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionsModel class
 */

#include <stdexcept>
#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "NodeModel.hpp"

PartitionsModel::PartitionsModel(Audio::Partitions *partitions, NodeModel *parent) noexcept
    : QAbstractListModel(parent), _data(partitions), _instances(&partitions->headerCustomType().instances, this)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _instances->connect(_instances.get(), &PartitionInstancesModel::latestInstanceChanged, this, &PartitionsModel::processLatestInstanceChange);
    _partitions.reserve(_data->size());
    for (auto &partition : *_data)
        _partitions.push(&partition, this);
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
        throw std::range_error("PartitionsModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    switch (static_cast<PartitionsModel::Roles>(role)) {
    case Roles::Partition:
        return QVariant::fromValue(PartitionWrapper { const_cast<PartitionModel *>(get(index.row())) });
    default:
        return QVariant();
    }
}

void PartitionsModel::processLatestInstanceChange(void)
{
    const Beat newInstance = _instances->count() ? _instances->audioInstances()->back().range.to : 0u;

    if (_latestInstance < newInstance) {
        const auto oldLatest = _latestInstance;
        _latestInstance = newInstance;
        emit latestInstanceChanged();
        parentNode()->processLatestInstanceChange(oldLatest, _latestInstance);
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
    const auto oldData = _data->data();

    return Models::AddProtectedEvent(
        [this](void) mutable {
           _data->push();
        },
        [this, name = getAvailablePartitionName(), oldData] {
            if (_data->data() != oldData) {
                refreshPartitions();
                _partitions.back()->setName(name);
            } else {
                const auto idx = _partitions.size();
                beginInsertRows(QModelIndex(), idx, idx);
                _partitions.push(&_data->at(idx), this, name);
                endInsertRows();
            }
        }
    );
}

bool PartitionsModel::duplicate(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionsModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    const auto oldData = _data->data();

    return Models::AddProtectedEvent(
        [this, idx] {
           auto &partition = _data->push();
           auto &source = _data->at(static_cast<std::uint32_t>(idx));
           partition = source;
        },
        [this, oldData, idx] {
            PartitionModel *partition = getPartition(idx);
            QString name = partition->name() + tr(" Copy");
            if (_data->data() != oldData) {
                refreshPartitions();
                _partitions.back()->setName(name);
            } else {
                const auto idx = _partitions.size();
                beginInsertRows(QModelIndex(), idx, idx);
                _partitions.push(&_data->at(idx), this, name);
                endInsertRows();
            }
        }
    );
}

bool PartitionsModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionsModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, idx] {
            _data->erase(_data->begin() + idx);
            _instances->partitionRemovedUnsafe(idx);
        },
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _partitions.erase(_partitions.begin() + idx);
            endRemoveRows();
            const auto count = _partitions.size();
            for (auto i = static_cast<std::uint32_t>(idx); i < count; ++i)
                _partitions.at(i)->updateInternal(&_data->at(i));
            _instances->partitionRemovedNotify();
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
    auto scheduler = Scheduler::Get();
    const bool isPlaying = !scheduler->hasExitedGraph();
    const bool graphChanged = scheduler->partitionNode() != node->audioNode() || scheduler->partitionIndex() != partitionIndex;
    bool hasPaused = false;

    if (isPlaying && graphChanged)
        hasPaused = scheduler->pauseImpl();
    scheduler->addEvent(
        [this, note] {
            if (/* note.type != Audio::NoteEvent::EventType::OnOff && */ note.type != Audio::NoteEvent::EventType::PolyPressure) {
                auto &notesOnTheFly = _data->headerCustomType().notesOnTheFly;
                if (auto it = std::remove_if(notesOnTheFly.begin(), notesOnTheFly.end(), [note](const NoteEvent evt) {
                    return (
                        note.key == evt.key &&
                        note.sampleOffset == evt.sampleOffset &&
                        note.type != evt.type
                    );
                });     it == notesOnTheFly.end()) {
                    notesOnTheFly.push(note);
                } else {
                    notesOnTheFly.erase(it, notesOnTheFly.end());
                }
            } else
                _data->headerCustomType().notesOnTheFly.push(note);
            Scheduler::Get()->resetOnTheFlyMiss();
        },
        [this, node, partitionIndex, isPlaying, graphChanged, hasPaused] {
            const auto scheduler = Scheduler::Get();
            if (hasPaused)
                scheduler->graph().wait();
            if (!isPlaying || graphChanged)
                scheduler->playPartition(Scheduler::PlaybackMode::OnTheFly, node, partitionIndex, 0);
        }
    );
}

bool PartitionsModel::foreignPartitionInstanceCopy(PartitionModel *partition, const PartitionInstance &instance)
{
    QString name = getAvailablePartitionName() + " (" + partition->parentPartitions()->parentNode()->name() + " - " + partition->name() + ")";
    const auto oldData = _data->data();

    return Models::AddProtectedEvent(
        [this, partition] {
            _data->push(*partition->audioPartition());
        },
        [this, oldData, partition, instance, name] {
            if (_data->data() != oldData) {
                refreshPartitions();
                _partitions.back()->setName(name);
            } else {
                const auto idx = _partitions.size();
                beginInsertRows(QModelIndex(), idx, idx);
                _partitions.push(&_data->at(idx), this, name);
                endInsertRows();
            }
            auto newInstance = instance;
            newInstance.partitionIndex = _partitions.size() - 1;
            _instances->add(newInstance);
        }
    );
}

void PartitionsModel::refreshPartitions(void)
{
    Models::RefreshModels(this, _partitions, *_data, this);
    _instances->updateInternal(&_data->headerCustomType().instances);
}

QString PartitionsModel::getAvailablePartitionName(void) const noexcept
{
    QString name;
    auto size = _partitions.size();
    while (true) {
        bool unique = true;
        name = "Partition " + QString::number(size);
        for (const auto &partition : _partitions) {
            if (partition->name() == name) {
                unique = false;
                break;
            }
        }
        if (unique)
            break;
        ++size;
    }
    return name;
}
