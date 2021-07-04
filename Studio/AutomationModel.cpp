/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Automation Model class
 */

#include <QHash>
#include <QQmlEngine>

#include "Models.hpp"
#include "AutomationModel.hpp"
#include "Scheduler.hpp"

AutomationModel::AutomationModel(Audio::Automation *automation, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(automation)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> AutomationModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Point), "point" }
    };
}

QVariant AutomationModel::data(const QModelIndex &index, int role) const
{
    const auto &child = get(index.row());

    switch (static_cast<Roles>(role)) {
    case Roles::Point:
        return QVariant::fromValue(reinterpret_cast<const GPoint &>(child));
    default:
        return QVariant();
    }
}

bool AutomationModel::muted(void) const noexcept
{
    if (_data->isSafe())
        return _data->headerCustomType().muted;
    return true;
}

void AutomationModel::setMuted(const bool muted)
{
    if (bool value = true; _data->isSafe()) {
        value = _data->headerCustomType().muted;
        Models::AddProtectedEvent(
            [this, muted] {
                _data->headerCustomType().muted = muted;
            },
            [this, value] {
                if (value != _data->headerCustomType().muted)
                    emit mutedChanged();
            }
        );
    }
}

bool AutomationModel::add(const GPoint &point)
{
    const auto idx = static_cast<int>(std::distance(_data->begin(), _data->findSortedPlacement(point)));

    return Models::AddProtectedEvent(
        [this, point] {
            _data->insert(point);
        },
        [this, idx] {
            beginInsertRows(QModelIndex(), idx, idx);
            endInsertRows();
        }
    );
}

bool AutomationModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("AutomationModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _data->erase(_data->begin() + idx);
        },
        [this] {
            endRemoveRows();
        }
    );
}

const GPoint &AutomationModel::get(const int idx) const noexcept_ndebug
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("AutomationModel::get: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));

    return reinterpret_cast<const GPoint &>(_data->at(idx));
}

bool AutomationModel::set(const int idx, const GPoint &point)
{
    auto newIdx = static_cast<int>(std::distance(_data->begin(), _data->findSortedPlacement(point)));

    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("AutomationModel::set: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, point, idx] {
            _data->assign(idx, point);
        },
        [this, idx, newIdx] {
            if (idx != newIdx) {
                beginMoveRows(QModelIndex(), idx, idx, QModelIndex(), newIdx ? newIdx + 1 : 0);
                endMoveRows();
            } else {
                const auto modelIndex = index(idx);
                emit dataChanged(modelIndex, modelIndex);
            }
        }
    );
}

bool AutomationModel::removeSelection(const BeatRange &range)
{
    if (!_data)
        return false;
    return Models::AddProtectedEvent(
        [this, range] {
            auto it = std::remove_if(_data->begin(), _data->end(), [&range](const auto &point) {
                return point.beat >= range.from && point.beat <= range.to;
            });
            if (it != _data->end())
                _data->erase(it, _data->end());
        },
        [this, oldCount = _data->size()] {
            if (oldCount != _data->size()) {
                beginResetModel();
                endResetModel();
            }
        }
    );
}

void AutomationModel::updateInternal(Audio::Automation *data)
{
    if (_data == data)
        return;
    std::swap(_data, data);
    if (_data->data() != data->data()) {
        beginResetModel();
        endResetModel();
    }
}
