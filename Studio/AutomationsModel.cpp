/**
 * @ Author: Gonzalez Dorian
 * @ Description: Automations Model implementation
 */

#include <QQmlEngine>
#include <QHash>

#include "Models.hpp"
#include "NodeModel.hpp"

AutomationsModel::AutomationsModel(Audio::Automations *automations, NodeModel *parent) noexcept
    : QAbstractListModel(parent), _data(automations)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
    _automations.reserve(_data->size());
    for (auto &automation : *_data)
        _automations.push(&automation, this);
}

QHash<int, QByteArray> AutomationsModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(AutomationsModel::Roles::Automation), "automationInstance" }
    };
}

QVariant AutomationsModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("AutomationsModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    switch (static_cast<AutomationsModel::Roles>(role)) {
        case AutomationsModel::Roles::Automation:
            return QVariant::fromValue(AutomationWrapper { const_cast<AutomationModel *>(get(index.row())) });
        default:
            return QVariant();
    }
}

const AutomationModel *AutomationsModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::range_error("AutomationsModel::get: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    return _automations.at(index).get();
}

void AutomationsModel::refreshAutomations(void)
{
    Models::RefreshModels(this, _automations, *_data, this);
}
