/**
 * @ Author: Cédric Lucchese
 * @ Description: Settings Model
 */

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

#include "SettingsListModel.hpp"

QHash<int, QByteArray> SettingsListModel::roleNames(void) const
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Role::Category), "category" },
        { static_cast<int>(Role::ID), "roleID" },
        { static_cast<int>(Role::Name), "name" },
        { static_cast<int>(Role::Help), "help" },
        { static_cast<int>(Role::Tags), "tags" },
        { static_cast<int>(Role::Type), "type" },
        { static_cast<int>(Role::CurrentValue), "currentValue" },
        { static_cast<int>(Role::Values), "values" }
    };
}

int SettingsListModel::rowCount(const QModelIndex &parent) const
{
    return _models.size();
}

QVariant SettingsListModel::data(const QModelIndex &index, int role) const
{
    auto &model = _models[index.row()];

    switch (static_cast<Role>(role)) {
    case Role::Category:
        return model.category;
    case Role::ID:
        return model.id;
    case Role::Name:
        return model.name;
    case Role::Help:
        return model.help;
    case Role::Tags:
        return model.tags;
    case Role::Type:
        return model.type;
    case Role::CurrentValue:
        return model.currentValue;
    case Role::Values:
        return model.values;
    default:
        return model.name;
    }
}

bool SettingsListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    auto &model = _models[index.row()];

    switch (static_cast<Role>(role)) {
        case Role::CurrentValue:
            model.currentValue = value;
            break;
        default:
            break;
    }
    return true;
}

bool SettingsListModel::read(const QString &settings, const QString &values)
{
    jsonSettingsFile.setFileName(settings);
    jsonValuesFile.setFileName(values);

    jsonSettingsFile.open(QIODevice::ReadOnly | QIODevice::Text);
    if (!jsonSettingsFile.exists())
        throw std::logic_error("SettingsListModel::read: No settings file");
    jsonSettingsStr = jsonSettingsFile.readAll();
    jsonSettingsFile.close();

    jsonValuesFile.open(QIODevice::ReadOnly | QIODevice::Text);
    if (jsonValuesFile.exists())
        jsonValuesStr = jsonValuesFile.readAll();
    jsonValuesFile.close();
    return true;
}

bool SettingsListModel::load() noexcept
{
    if (jsonSettingsStr.isEmpty())
        return false;

    QJsonDocument docSettings = QJsonDocument::fromJson(jsonSettingsStr.toUtf8());
    QJsonDocument docValues = QJsonDocument::fromJson(jsonValuesStr.toUtf8());
    QJsonObject objSettings = docSettings.object();
    QJsonObject objValues = docValues.object();

    beginResetModel();
    _models.clear();
    parse(objSettings, objValues, "");
    endResetModel();
    return true;
}

void SettingsListModel::parse(const QJsonObject &objSettings, QJsonObject &objValues, QString path)
{
    for (unsigned int i = 0; i < objSettings.keys().count(); i++) {
        auto child = objSettings[objSettings.keys().at(i)];
        if (child.isObject()) {
            parse(child.toObject(), objValues, path + "/" + objSettings.keys().at(i));
            continue;
        } if (child.isArray()) {
            auto array = child.toArray();

            for (auto it = array.begin(); it != array.end(); it++) {
                auto obj = it->toObject();

                if (!objValues.contains(obj["id"].toString())) {
                    if (!obj["start"].isNull())
                        objValues.insert(obj["id"].toString(), obj["start"]);
                    else
                        objValues.insert(obj["id"].toString(), obj["values"].toArray().first());
                }

                _models.push_back({
                    category: path + "/" + objSettings.keys().at(i),
                    id: obj["id"].toString(),
                    name: obj["name"].toString(),
                    help: obj["help"].toString(),
                    tags: obj["tags"].toArray().toVariantList(),
                    type: obj["type"].toString(),
                    currentValue: objValues.value(obj["id"].toString()).toVariant(),
                    values: obj["values"].toArray().toVariantList()
                });
            }
        }
    }
}

bool SettingsListModel::saveValues() noexcept
{
    jsonValuesFile.open(QIODevice::WriteOnly | QFile::Truncate);
    QVariantMap map;
    for (auto it = _models.begin(); it != _models.end(); it++)
        map.insert(it->id, it->currentValue);
    QJsonDocument doc(QJsonDocument::fromVariant(map));
    jsonValuesFile.write(doc.toJson(QJsonDocument::Indented));
    jsonValuesFile.close();
    return true;
}