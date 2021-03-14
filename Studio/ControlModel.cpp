/**
 * @ Author: Gonzalez Dorian
 * @ Description: Control Model class
 */

#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "ControlModel.hpp"
#include "Scheduler.hpp"

ControlModel::ControlModel(Audio::Control *control, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(control)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _automations.reserve(_data->automations().size());
    for (auto &automation : _data->automations())
        _automations.push(&automation, this);
}

QHash<int, QByteArray> ControlModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(ControlModel::Roles::AutomationInstance), "automation"}
    };
}

QVariant ControlModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("ControlModel::get: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    switch (static_cast<ControlModel::Roles>(role)) {
    case ControlModel::Roles::AutomationInstance:
        return QVariant::fromValue(AutomationWrapper { const_cast<AutomationModel *>(get(index.row())) });
    default:
        return QVariant();
    }
}

const AutomationModel *ControlModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("ControlModel::get: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    return _automations.at(index).get();
}

bool ControlModel::setParamID(const ParamID paramID) noexcept
{
    if (!_data->setParamID(paramID))
        return false;
    emit paramIDChanged();
    return true;
}

bool ControlModel::setMuted(const bool muted) noexcept
{
    if (!_data->setMuted(muted))
        return false;
    emit mutedChanged();
    return true;
}

bool ControlModel::setManualMode(const bool manualMode) noexcept
{
    if (!_data->setManualMode(manualMode))
        return false;
    emit manualModeChanged();
    return true;
}

bool ControlModel::setManualPoint(const GPoint &manualPoint) noexcept
{
    if (!_data->setManualPoint(manualPoint))
        return false;
    emit manualPointChanged();
    return true;
}

void ControlModel::refreshAutomations(void)
{
    Models::RefreshModels(_automations, _data->automations(), this);
}

void ControlModel::updateInternal(Audio::Control *data)
{
    if (_data == data)
        return;
    Scheduler::Get()->addEvent(
        [this, data] {
            _data = data;
        },
        [this, data] {
            if (_data->automations().data() != data->automations().data()) {
                beginResetModel();
                refreshAutomations();
                endResetModel();
            }
        });

}

void ControlModel::add(void)
{
    Scheduler::Get()->addEvent(
        [this] {
            _data->automations().push(Audio::Automation());
        },
        [this] {
            beginResetModel();
            refreshAutomations();
            endResetModel();
        });
}

void ControlModel::remove(const int index)
{
    if (index >= count())
        return;
    Scheduler::Get()->addEvent(
        [this, index] {
            auto it = _data->automations().begin() + index;
            if (it != _data->automations().end() && it != nullptr)
                _data->automations().erase(it);
        }, [this] {
            beginResetModel();
            refreshAutomations();
            endResetModel();
        });

}

void ControlModel::move(const int from, const int to)
{
}