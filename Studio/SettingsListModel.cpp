/**
 * @ Author: Matthieu Moinvaziri
 * @ Description: Settings Model
 */

#include "SettingsListModel.hpp"

QHash<int, QByteArray> SettingsListModel::roleNames(void) const
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Role::Category), "category" },
        { static_cast<int>(Role::Subcategory), "subcategory" },
        { static_cast<int>(Role::Name), "name" },
        { static_cast<int>(Role::Description), "description" },
        { static_cast<int>(Role::Tags), "tags" },
        { static_cast<int>(Role::Type), "type" },
        { static_cast<int>(Role::Value), "value" },
        { static_cast<int>(Role::Range), "range" }
    };
}

int SettingsListModel::rowCount(const QModelIndex &parent) const
{
    return  _models.size();
}

QVariant SettingsListModel::data(const QModelIndex &index, int role) const
{
    auto &model = _models[index.row()];

    switch (static_cast<Role>(role)) {
    case Role::Category:
        return model.category;
    case Role::Subcategory:
        return model.subcategory;
    case Role::Name:
        return model.name;
    case Role::Description:
        return model.description;
    case Role::Tags:
        return model.tags;
    case Role::Type:
        return model.type;
    case Role::Value:
        return model.value;
    case Role::Range:
        return model.range;
    default:
        return model.name;
    }
}

