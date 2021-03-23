/**
 * @ Author: Gonzalez Dorian
 * @ Description: Controls Model implementation
 */

#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "NodeModel.hpp"

ControlsModel::ControlsModel(Audio::Controls *controls, NodeModel *parent) noexcept
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
        { static_cast<int>(ControlsModel::Roles::Control), "controlInstance" }
    };
}

QVariant ControlsModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("ControlsModel::get: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    switch (static_cast<ControlsModel::Roles>(role)) {
        case ControlsModel::Roles::Control:
            return QVariant::fromValue(ControlWrapper { const_cast<ControlModel *>(get(index.row())) });
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

void ControlsModel::add(const ParamID paramID)
{
    QString name = "Control " + QString::number(paramID);

    Models::AddProtectedEvent(
        [this, paramID] {
            _data->push(paramID);
        },
        [this, name] {
            const auto controlsData = _controls.data();
            const auto idx = _controls.size();
            beginInsertRows(QModelIndex(), idx, idx);
            _controls.push(&_data->at(idx), this)->setName(name);
            endInsertRows();
            if (_controls.data() != controlsData)
                refreshControls();
        }
    );
}

void ControlsModel::remove(const int idx)
{
    coreAssert(idx >= 0 && idx < count(),
        throw std::range_error("ControlsModel::remove: Given index is not in range: " + std::to_string(idx) + " out of [0, " + std::to_string(count()) + "["));
    Models::AddProtectedEvent(
        [this, idx] {
            _data->erase(_data->begin() + idx);
        },
        [this, idx] {
            beginRemoveRows(QModelIndex(), idx, idx);
            _controls.erase(_controls.begin() + idx);
            endRemoveRows();
            const auto count = _controls.size();
            for (auto i = static_cast<std::size_t>(idx); i < count; ++i)
                _controls.at(i)->updateInternal(&_data->at(i));
        }
    );
}

void ControlsModel::move(const int from, const int to)
{
    if (from == to)
        return;
    coreAssert(from >= 0 && from < count() && to >= 0 && to < count(),
        throw std::range_error("ControlModel::move: Given index is not in range: [" + std::to_string(from) + ", " + std::to_string(to) + "[ out of [0, " + std::to_string(count()) + "["));
    Models::AddProtectedEvent(
        [this, from, to] {
            _data->move(from, from, to);
        },
        [this, from, to] {
            beginMoveRows(QModelIndex(), from, from, QModelIndex(), to + 1);
            _controls.move(from, from, to);
            endMoveRows();
            _controls.at(from)->updateInternal(&_data->at(from));
            _controls.at(to)->updateInternal(&_data->at(to));
        }
    );
}

void ControlsModel::refreshControls(void)
{
    Models::RefreshModels(this, _controls, *_data, this);
}