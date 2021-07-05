/**
 * @ Author: Cédric Lucchese
 * @ Description: PartitionModel class
 */

#include <stdexcept>

#include <QHash>
#include <QQmlEngine>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include "Models.hpp"
#include "PartitionsModel.hpp"

PartitionModel::PartitionModel(Audio::Partition *partition, PartitionsModel *parent, const QString &name) noexcept
    : QAbstractListModel(parent), _data(partition), _name(name)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PartitionModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Range),       "range" },
        { static_cast<int>(Roles::Velocity),    "velocity" },
        { static_cast<int>(Roles::Tuning),      "tuning" },
        { static_cast<int>(Roles::NoteIndex),   "noteIndex" },
        { static_cast<int>(Roles::EventType),   "eventType" },
        { static_cast<int>(Roles::Key),         "key" }
    };
}

QVariant PartitionModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("PartitionModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    const auto &child = _data->at(index.row());
    switch (static_cast<Roles>(role)) {
        case Roles::Range:
            return QVariant::fromValue(reinterpret_cast<const BeatRange &>(child.range));
        case Roles::Velocity:
            return child.velocity;
        case Roles::Tuning:
            return child.tuning;
        case Roles::Key:
            return child.key;
        default:
            return QVariant();
    }
}

void PartitionModel::setName(const QString &name)
{
    if (_name == name)
        return;
    _name = name;
    emit nameChanged();
}

bool PartitionModel::add(const Note &note)
{
    const auto idx = static_cast<int>(std::distance(_data->begin(), _data->findSortedPlacement(note)));

    return Models::AddProtectedEvent(
        [this, note] {
            _data->insert(note);
        },
        [this, idx] {
            beginInsertRows(QModelIndex(), idx, idx);
            endInsertRows();
            const auto last = _data->back().range.to;
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

int PartitionModel::find(const quint8 key, const quint32 beat) const noexcept
{
    int idx = 0;

    for (const auto &note : *_data) {
        if (note.key != key || beat < note.range.from || beat > note.range.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

int PartitionModel::findExact(const Note &note) const noexcept
{
    int idx = 0;

    for (const auto &elem : *_data) {
        if (elem == note)
            return idx;
        ++idx;
    }
    return -1;
}

int PartitionModel::findOverlap(const Key key, const BeatRange &range) const noexcept
{
    int idx = 0;

    for (const auto &note : *_data) {
        if (note.key != key || range.to < note.range.from || range.from > note.range.to) {
            ++idx;
            continue;
        }
        return idx;
    }
    return -1;
}

bool PartitionModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _data->erase(_data->begin() + idx);
        },
        [this] {
            endRemoveRows();
            const Beat last = _data->empty() ? 0u : _data->back().range.to;
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

const Note &PartitionModel::get(const int idx) const noexcept_ndebug
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    return reinterpret_cast<const Note &>(_data->at(idx));
}

void PartitionModel::set(const int idx, const Note &note)
{
    auto newIdx = static_cast<int>(std::distance(_data->begin(), _data->findSortedPlacement(note)));

    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionModel::move: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    Scheduler::Get()->addEvent(
        [this, note, idx] {
            _data->assign(idx, note);
        },
        [this, idx, newIdx] {
            if (idx != newIdx) {
                beginResetModel(); // @todo fix all 'set'
                endResetModel();
            } else {
                const auto modelIndex = index(idx);
                emit dataChanged(modelIndex, modelIndex);
                const auto last = _data->back().range.to;
                if (last > _latestNote) {
                    _latestNote = last;
                    emit latestNoteChanged();
                }
            }
            emit notesChanged();
        }
    );
}

bool PartitionModel::addRangeProcess(const QVector<Note> notes)
{
    return Models::AddProtectedEvent(
        [this, notes] {
            _data->insert(notes.begin(), notes.end());
        },
        [this] {
            beginResetModel();
            endResetModel();
            const auto last = _data->back().range.to;
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

bool PartitionModel::addRange(const QVariantList &noteList)
{
    if (noteList.empty())
        return true;
    else if (noteList.size() == 1)
        return add(noteList.front().value<Note>());
    QVector<Note> notes;
    notes.reserve(noteList.size());
    for (const auto &n : noteList)
        notes.append(n.value<Note>());
    return addRangeProcess(notes);
}

bool PartitionModel::addJsonRange(const QString &json, int scale)
{
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
    QJsonObject obj = doc.object();
    QJsonArray arr = obj["Notes"].toArray();
    if (arr.size() <= 0)
        return true;

    QVector<Note> notes;
    notes.reserve(arr.size());

    auto offset = 0;
    QJsonObject note = arr[0].toObject();
    while ((find(note["key"].toInt(), note["from"].toInt() + 1 + offset) != -1))
        offset += scale;
    for (int idx = 0; idx < arr.size(); ++idx) {
        QJsonObject note = arr[idx].toObject();
        BeatRange range { static_cast<Audio::Beat>(note["from"].toInt() + offset), static_cast<Audio::Beat>(note["to"].toInt() + offset) };
        notes.push_back({ range, static_cast<Audio::Key>(note["key"].toInt()), static_cast<Audio::Velocity>(note["velocity"].toInt()), static_cast<Audio::Tuning>(note["tuning"].toInt()) });
    }
    return addRangeProcess(notes);
}

bool PartitionModel::removeRange(const QVariantList &indexes)
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
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

QVariantList PartitionModel::select(const BeatRange &range, const Key keyFrom, const Key keyTo)
{
    int idx = 0;
    QVariantList indexes;

    for (const auto &note : *_data) {
        if (note.key >= keyFrom && note.key <= keyTo && note.range.from <= range.to && note.range.to >= range.from)
            indexes.append(idx);
        ++idx;
    }
    return indexes;
}

void PartitionModel::updateInternal(Audio::Partition *data)
{
    if (_data == data)
        return;
    Scheduler::Get()->addEvent(
        [this, data] {
            _data = data;
        },
        [this, data] {
            if (_data->data() != data->data()) {
                beginResetModel();
                endResetModel();
                emit notesChanged();
            }
        }
    );
}
