/**
 * @ Author: Gonzalez Dorian
 * @ Description: Control Model class
 */

#include "ControlModel.hpp"

ControlModel::ControlModel(QObject *parent, Audio::Control *control) noexcept;
    : QAbstractListModel(parent), _data(control)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _automations.reserve(_data->automations().size());
    for (auto &automation : _data->automations())
        _automations.push(&automation);
}

QHash<int, QByteArray> ControlModel::roleNames(void) const noexcept override
{
    return QHash<int, QByteArray> {
        { Roles::Automation, "automation"},
        { Roles::Muted, "muted"}
    };
}

QVariant ControlModel::data(const QModelIndex &index, int role) const override
{
    switch (role) {
    case Roles::Automation:
        return get(index.row());
    case Roles::Muted:
        return isAutomationMuted(index.row());
    default:
        return QVariant();
    }
}

void ControlModel::setData(const QModelIndex &index, const QVariant &value, int role) override
{
    switch (role) {
    case Roles::Muted:
        setAutomationMutedState(index.row(), value.toBool());
        break;
    default:
        throw std::logic_error("ControlModel::setData: Couldn't change invalid role");
    }
}

AutomationModel *ControlModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index < 0 || index >= count(),
        throw std::range_error("ControlModel::get: Given index is not in range"));
    return _automations.at(index).get();
}

bool ControlModel::isAutomationMuted(const int index) const noexcept_ndebug
{
    coreAssert(index < 0 || index >= count(),
        throw std::range_error("ControlModel::isAutomationMuted: Given index is not in range"));
    return _data->isAutomationMuted(index);
}


bool ControlModel::setAutomationMutedState(const int index, const bool state) noexcept_ndebug
{
    coreAssert(index < 0 || index >= count(),
        throw std::range_error("ControlModel::isAutomationMuted: Given index is not in range"));
    return _data->setAutomationMutedState(index, state);
}

void ControlModel::add(void)
{
}

void ControlModel::remove(const int index) noexcept_ndebug
{
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

}