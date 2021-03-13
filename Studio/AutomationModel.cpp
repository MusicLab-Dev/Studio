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
        return child.beat;
    default:
        return QVariant();
    }
}

bool AutomationModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    switch (static_cast<Roles>(role)) {
    case Roles::Point:
        set(index.row(), value.value<GPoint>());
        return true;
    default:
        throw std::logic_error("ControlModel::setData: Couldn't change invalid role");
    }
}

void AutomationModel::add(const GPoint &point) noexcept
{
    Scheduler::Get()->addEvent(
        [this, &point] {
            _data->points().push(point);
        },
        [this] {
            beginResetModel();
            endResetModel();
        });
}

void AutomationModel::remove(const int index) noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("AutomationModel::remove: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));

    Scheduler::Get()->addEvent(
        [this, &index] {
            _data->points().erase(_data->points().begin() + index);
        },
        [this, &index] {
            beginRemoveRows(QModelIndex(), index, index);
            endRemoveRows();
        });
}

GPoint AutomationModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("AutomationModel::get: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));

    return GPoint { _data->points().at(index) };
}

void AutomationModel::set(const int index, const GPoint &point) noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("AutomationModel::set: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));

    Scheduler::Get()->addEvent(
        [this, &index, &point] {
            _data->points().at(index) = point;
            // _data->points().sort()
        },
        [this, &index] {
            beginResetModel();
            endResetModel();
            const auto modelIndex = QAbstractListModel::index(index, 0);
            emit dataChanged(modelIndex, modelIndex, { static_cast<int>(Roles::Point) });
        });

}

void AutomationModel::updateInternal(Audio::Automation *data)
{
    if (_data == data)
        return;
    Scheduler::Get()->addEvent(
        [this, data] {
            _data = data;
            _instances->updateInternal(&_data->instances());
        },
        [this, data] {
            if (_data->points().data() != data->points().data()) {
                beginResetModel();
                endResetModel();
            }
        });
}