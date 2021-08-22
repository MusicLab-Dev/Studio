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
    if (_data && !_data->empty())
        _latestNote = _data->back().range.to;
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
            onNotesChanged();
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

    for (const auto &n : *_data) {
        if (n == note)
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
            onNotesChanged();
        }
    );
}

const Note &PartitionModel::get(const int idx) const noexcept_ndebug
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("PartitionModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    return reinterpret_cast<const Note &>(_data->at(idx));
}

QVector<Note> PartitionModel::getNotes(const QVector<int> &indexes) const noexcept
{
    QVector<Note> notes;

    notes.reserve(indexes.size());
    for (const auto idx : indexes) {
        notes.push_back(get(idx));
    }
    return notes;
}

NotesAnalysis PartitionModel::getNotesAnalysis(const QVector<Note> &notes) const noexcept
{
    if (notes.empty())
        return NotesAnalysis {};

    NotesAnalysis analysis {
        /* from: */         std::numeric_limits<Beat>::max(),
        /* to: */           0u,
        /* distance: */     0u,
        /* min: */          std::numeric_limits<Key>::max(),
        /* max: */          0u
    };

    for (const auto &note : notes) {
        analysis.from = std::min(analysis.from, note.range.from);
        analysis.to = std::max(analysis.to, note.range.to);
        analysis.min = std::min(analysis.min, note.key);
        analysis.max = std::max(analysis.max, note.key);
    }
    analysis.distance = analysis.to - analysis.from;
    return analysis;
}

bool PartitionModel::hasOverlap(const NotesAnalysis &analysis) const noexcept
{
    for (const auto &elem : *_data) {
        if (analysis.to <= elem.range.from || analysis.from >= elem.range.to
                || elem.key < analysis.min || elem.key > analysis.max) {
            continue;
        } else
            return true;
    }
    return false;
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
            }
            onNotesChanged();
        }
    );
}

bool PartitionModel::setRange(const QVector<Note> &before, const QVector<Note> &after)
{
    coreAssert(before.size() == after.size(),
        throw std::logic_error("PartitionModel::setRange: Invalid mismatch count of before / after notes"));

    QVector<int> indexes;
    QVector<Note> res;
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
            onNotesChanged();
        }
    );
}

bool PartitionModel::addRange(const QVector<Note> &notes)
{
    if (notes.isEmpty())
        return true;
    return Models::AddProtectedEvent(
        [this, notes] {
            _data->insert(notes.begin(), notes.end());
        },
        [this] {
            beginResetModel();
            endResetModel();
            onNotesChanged();
        }
    );
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
    while ((find(static_cast<Key>(note["key"].toInt()), static_cast<Beat>(note["from"].toInt()) + 1 + offset) != -1))
        offset += scale;
    for (int idx = 0; idx < arr.size(); ++idx) {
        QJsonObject note = arr[idx].toObject();
        BeatRange range { static_cast<Beat>(note["from"].toInt() + offset), static_cast<Beat>(note["to"].toInt() + offset) };
        notes.push_back({ range, static_cast<Key>(note["key"].toInt()), static_cast<Velocity>(note["velocity"].toInt()), static_cast<Tuning>(note["tuning"].toInt()) });
    }
    return addRange(notes);
}

bool PartitionModel::removeRange(const QVector<int> &indexes)
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
            const Beat last = _data->empty() ? 0u : _data->back().range.to;
            if (last > _latestNote) {
                _latestNote = last;
                emit latestNoteChanged();
            }
            emit notesChanged();
        }
    );
}

bool PartitionModel::removeExactRange(const QVector<Note> &notes)
{
    QVector<int> indexes;

    for (const auto &note : notes) {
        int idx = findExact(note);
        if (idx != -1)
            indexes.push_back(idx);
    }
    return removeRange(indexes);
}

QVector<int> PartitionModel::select(const BeatRange &range, const Key keyFrom, const Key keyTo)
{
    int idx = 0;
    QVector<int> indexes;

    for (const auto &note : *_data) {
        if (note.key >= keyFrom && note.key <= keyTo && note.range.from <= range.to && note.range.to >= range.from)
            indexes.push_back(idx);
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

void PartitionModel::onNotesChanged(void)
{
    const Beat last = !_data->empty() ?_data->back().range.to : 0u;

    if (last > _latestNote) {
        _latestNote = last;
        emit latestNoteChanged();
    }
    emit notesChanged();
}
