/**
 * @ Author: Gonzalez Dorian
 * @ Description: Controls Model implementation
 */

#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "ControlsModel.hpp"

ControlsModel::ControlsModel(Audio::Controls *controls, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(controls)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);

    _controls.reserve(_data->size());
    for (auto &control : *_data)
        _controls.push(&control);
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
        throw std::range_error("ControlsModel::get: Given index is not in range"));
    return _controls.at(index).get();
}

void ControlsModel::add(const Audio::ParamID paramID) noexcept_ndebug
{
    beginInsertRows(QModelIndex(), count(), count());
    //_data->push();
    refreshControls();
    endInsertRows();
}

void ControlsModel::remove(const int index) noexcept_ndebug
{
    beginRemoveRows(QModelIndex(), index, index);
    //_data->erase(_data->begin() + index);
    //_controls.erase(_controls.begin() + index);
    refreshControls();
    endRemoveRows();
}

void ControlsModel::move(const int from, const int to)
{
    beginMoveRows(QModelIndex(), from, from, QModelIndex(), to);
    //_data->at(from).swap(_data->at(to));
    refreshControls();
    endMoveRows();
}

void ControlsModel::refreshControls(void)
{
    Models::RefreshModels(_controls, *_data, this);
}