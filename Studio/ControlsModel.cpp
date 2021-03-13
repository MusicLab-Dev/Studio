/**
 * @ Author: Gonzalez Dorian
 * @ Description: Controls Model implementation
 */

#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "ControlsModel.hpp"
#include "Scheduler.hpp"

ControlsModel::ControlsModel(Audio::Controls *controls, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(controls)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);

    Scheduler::Get()->addEvent([this] {
        _controls.reserve(_data->size());
        for (auto &control : *_data)
            _controls.push(&control);
    });
}

QHash<int, QByteArray> ControlsModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(ControlsModel::Roles::Control), "control" }
    };
}

QVariant ControlsModel::data(const QModelIndex &index, int role) const
{
    switch (static_cast<ControlsModel::Roles>(role)) {
        case ControlsModel::Roles::Control:
            return get(index.row());
        default:
            return QVariant();
    }
}

const ControlModel *ControlsModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("ControlsModel::get: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    return _controls.at(index).get();
}

void ControlsModel::add(const ParamID paramID) noexcept_ndebug
{
    Scheduler::Get()->addEvent(
    [this, paramID] {
        _data->push(paramID, 0.0);
    },
    [this] {
        beginInsertRows(QModelIndex(), count(), count());
        refreshControls();
        endInsertRows();
    });
}

void ControlsModel::remove(const int index) noexcept_ndebug
{
    Scheduler::Get()->addEvent(
        [this, index] {
            _data->erase(_data->begin() + index);
            _controls.erase(_controls.begin() + index);
        },
        [this, index] {
            beginRemoveRows(QModelIndex(), index, index);
            refreshControls();
            endRemoveRows();
        });
}

void ControlsModel::move(const int from, const int to)
{
    Scheduler::Get()->addEvent(
        [this, from, to] {
            std::swap(_data->at(from), _data->at(to));
        },
        [this, from, to] {
            beginMoveRows(index(from), from, from, index(to), to);
            refreshControls();
            endMoveRows();
        });
}

void ControlsModel::refreshControls(void)
{
    Models::RefreshModels(_controls, *_data, this);
}