/**
 * @ Author: Gonzalez Dorian
 * @ Description: Automation Model class
 */

#include <QHash>
#include <QQmlEngine>

#include "Models.hpp"
#include "AutomationModel.hpp"
#include "Scheduler.hpp"

AutomationModel::AutomationModel(Audio::Automation *automation, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(automation), _instances(&automation->instances(), this)
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

void AutomationModel::setMuted(const bool muted)
{
    Models::AddProtectedEvent(
        [this, muted] {
            _data->setMuted(muted);
        },
        [this, muted = _data->muted()] {
            if (muted != _data->muted())
                emit mutedChanged();
        }
    );
}

void AutomationModel::setName(const QString &name)
{
    Models::AddProtectedEvent(
        [this, name = Core::FlatString(name.toStdString())](void) mutable { _data->setName(std::move(name)); },
        [this, name = _data->name()] {
            if (name != _data->name())
                emit nameChanged();
        }
    );
}

bool AutomationModel::add(const GPoint &point)
{
    const auto idx = static_cast<int>(std::distance(_data->points().begin(), _data->points().findSortedPlacement(point)));

    return Models::AddProtectedEvent(
        [this, point] {
            _data->points().insert(point);
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
            _data->points().erase(_data->points().begin() + idx);
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

    return reinterpret_cast<const GPoint &>(_data->points().at(idx));
}

bool AutomationModel::set(const int idx, const GPoint &point)
{
    auto newIdx = static_cast<int>(std::distance(_data->points().begin(), _data->points().findSortedPlacement(point)));

    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("AutomationModel::set: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    return Models::AddProtectedEvent(
        [this, point, idx] {
            _data->points().assign(idx, point);
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

void AutomationModel::updateInternal(Audio::Automation *data)
{
    if (_data == data)
        return;
    std::swap(_data, data);
    if (_data->points().data() != data->points().data()) {
        beginResetModel();
        endResetModel();
    }
    _instances->updateInternal(&_data->instances());
}
