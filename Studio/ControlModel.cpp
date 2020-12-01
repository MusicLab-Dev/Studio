/**
 * @ Author: Gonzalez Dorian
 * @ Description: Control Model class
 */

#include <QQmlEngine>
#include <QHash>

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
        { Roles::Automation, "automation"},
        { Roles::Muted, "muted"}
    };
}

QVariant ControlModel::data(const QModelIndex &index, int role) const
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

bool ControlModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    switch (role) {
    case Roles::Muted:
        setAutomationMutedState(index.row(), value.toBool());
        return true;
    default:
        throw std::logic_error("ControlModel::setData: Couldn't change invalid role");
    }
}

const AutomationModel *ControlModel::get(const int index) const noexcept_ndebug
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

void ControlModel::updateInternal(Audio::Control *data)
{
     if (_data == data)
        return;
    std::swap(_data, data);
    // Check if the underlying instances have different data pointer than new one
    if (_data->automations().data() != data->automations().data()) {
        beginResetModel();
        auto modelIt = _automations.begin();
        auto modelEnd = _automations.end();
        for (auto &automation : _data->automations()) {
            if (modelIt != modelEnd) {
                (*modelIt)->updateInternal(&automation);
                ++modelIt;
            } else {
                _automations.push(&automation, this);
                modelIt = _automations.begin() + std::distance(modelIt, modelEnd);
                modelEnd = _automations.end();
            }
        }
        endResetModel();
    }
}