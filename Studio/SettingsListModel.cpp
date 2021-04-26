/**
 * @ Author: Cédric Lucchese
 * @ Description: Settings Model
 */

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QDir>
#include <QStandardPaths>

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
        { static_cast<int>(Role::CurrentValue), "roleValue" },
        { static_cast<int>(Role::Values), "range" }
    };
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
    bool changed = false;

    switch (static_cast<Role>(role)) {
        case Role::CurrentValue:
            if (model.currentValue != value) {
                model.currentValue = value;
                changed = true;
            }
            break;
        default:
            break;
    }
    if (changed)
        emit dataChanged(index, index, { role });
    return true;
}

bool SettingsListModel::read(const QString &settings, const QString &values)
{
    _jsonSettingsFile.setFileName(settings);
    _jsonValuesFile.setFileName(values);

    _jsonSettingsFile.open(QIODevice::ReadOnly | QIODevice::Text);
    if (!_jsonSettingsFile.exists())
        throw std::logic_error("SettingsListModel::read: No settings file");
    _jsonSettingsStr = _jsonSettingsFile.readAll();
    _jsonSettingsFile.close();

    auto path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (path.isEmpty()) qFatal("SettingsListModel::read: Cannot determine settings storage location");
    QDir d{path};
    if (d.mkpath(d.absolutePath()) && QDir::setCurrent(d.absolutePath())) {
        _jsonValuesFile.open(QIODevice::ReadOnly | QIODevice::Text);
        if (_jsonValuesFile.exists())
            _jsonValuesStr = _jsonValuesFile.readAll();
        _jsonValuesFile.close();
    } else return false;
    return true;
}

bool SettingsListModel::load(const QString &settings, const QString &values) noexcept
{
    if (!read(settings, values) || _jsonSettingsStr.isEmpty())
        return false;

    QJsonDocument docSettings = QJsonDocument::fromJson(_jsonSettingsStr.toUtf8());
    QJsonDocument docValues = QJsonDocument::fromJson(_jsonValuesStr.toUtf8());
    QJsonObject objSettings = docSettings.object();
    QJsonObject objValues = docValues.object();

    beginResetModel();
    _models.clear();
    parse(objSettings, objValues, "");
    endResetModel();
    _jsonSettingsStr.clear();
    _jsonValuesStr.clear();
    return true;
}

void SettingsListModel::parse(const QJsonObject &objSettings, QJsonObject &objValues, QString path)
{
    for (int i = 0; i < objSettings.keys().count(); i++) {
        auto child = objSettings[objSettings.keys().at(i)];
        if (child.isObject()) {
            parse(child.toObject(), objValues, path + "/" + objSettings.keys().at(i));
            continue;
        } if (child.isArray()) {
            auto array = child.toArray();

            for (auto it = array.begin(); it != array.end(); it++) {
                auto obj = it->toObject();

                /** Create new fields in values */
                if (!objValues.contains(obj["id"].toString())) {
                    if (!obj["start"].isNull())
                        objValues.insert(obj["id"].toString(), obj["start"]);
                    else
                        objValues.insert(obj["id"].toString(), obj["values"].toArray().first());
                }

                _models.push_back({
                    /* category: */     path + "/" + objSettings.keys().at(i),
                    /* id: */           obj["id"].toString(),
                    /* name: */         obj["name"].toString(),
                    /* help: */         obj["help"].toString(),
                    /* tags: */         obj["tags"].toArray().toVariantList(),
                    /* type: */         obj["type"].toString(),
                    /* start: */        obj["start"].toString(),
                    /* currentValue: */ objValues.value(obj["id"].toString()).toVariant(),
                    /* values: */       obj["values"].toArray().toVariantList()
                });
            }
        }
    }
}

bool SettingsListModel::saveValues(void) noexcept
{
    _jsonValuesFile.open(QIODevice::WriteOnly | QFile::Truncate);
    QVariantMap map;
    for (auto it = _models.begin(); it != _models.end(); it++)
        map.insert(it->id, it->currentValue);
    QJsonDocument doc(QJsonDocument::fromVariant(map));
    _jsonValuesFile.write(doc.toJson(QJsonDocument::Indented));
    _jsonValuesFile.close();
    return true;
}

bool SettingsListModel::set(const QString &id, const QVariant &value) noexcept
{
    for (auto it = _models.begin(); it != _models.end(); it++) {
        if (it->id == id) {
            it->currentValue = value;
            return true;
        }
    }
    return false;
}

QVariant SettingsListModel::get(const QString &id) const noexcept
{
    for (auto it = _models.begin(); it != _models.end(); it++) {
        if (it->id == id)
            return it->currentValue;
    }
    return QVariant();
}
