/**
 * @ Author: Gonzalez Dorian
 * @ Description: Control Model class
 */

#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "ControlModel.hpp"

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
        { static_cast<int>(ControlModel::Roles::Automation), "automation"},
        { static_cast<int>(ControlModel::Roles::Muted), "muted"}
    };
}

QVariant ControlModel::data(const QModelIndex &index, int role) const
{
    switch (static_cast<ControlModel::Roles>(role)) {
    case ControlModel::Roles::Automation:
        return get(index.row());
    case ControlModel::Roles::Muted:
        return isAutomationMuted(index.row());
    default:
        return QVariant();
    }
}

bool ControlModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    switch (static_cast<ControlModel::Roles>(role)) {
    case Roles::Muted:
        setAutomationMutedState(index.row(), value.toBool());
        return true;
    default:
        throw std::logic_error("ControlModel::setData: Couldn't change invalid role");
    }
}

const AutomationModel *ControlModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("ControlModel::get: Given index is not in range"));
    return _automations.at(index).get();
}

bool ControlModel::isAutomationMuted(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("ControlModel::isAutomationMuted: Given index is not in range"));
    return _data->isAutomationMuted(index);
}


bool ControlModel::setAutomationMutedState(const int index, const bool state) noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("ControlModel::isAutomationMuted: Given index is not in range"));
    return _data->setAutomationMutedState(index, state);
}

void ControlModel::add(void)
{
    beginResetModel();
    _data->automations().push(Audio::Automation());
    refreshAutomations();
    endResetModel();
}

void ControlModel::remove(const int index)
{
    if (index >= count())
        return;
    beginResetModel();
    auto it = _data->automations().begin() + index;
    if (it != _data->automations().end() && it != nullptr)
        _data->automations().erase(it);
    refreshAutomations();
    endResetModel();
}

void ControlModel::move(const int from, const int to) noexcept_ndebug
{
}

bool ControlModel::setMuted(const bool muted) noexcept
{
    if (!_data->setMuted(muted))
        return false;
    emit mutedChanged();
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
    std::swap(_data, data);
    // Check if the underlying instances have different data pointer than new one
    if (_data->automations().data() != data->automations().data()) {
        beginResetModel();
        refreshAutomations();
        endResetModel();
    }
}