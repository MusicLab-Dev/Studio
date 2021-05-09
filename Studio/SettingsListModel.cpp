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

#include "SettingsListModel.hpp"

QHash<int, QByteArray> SettingsListModel::roleNames(void) const
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Category), "category" },
        { static_cast<int>(Roles::ID), "roleID" },
        { static_cast<int>(Roles::Name), "name" },
        { static_cast<int>(Roles::Help), "help" },
        { static_cast<int>(Roles::Tags), "tags" },
        { static_cast<int>(Roles::Type), "type" },
        { static_cast<int>(Roles::CurrentValue), "roleValue" },
        { static_cast<int>(Roles::Values), "range" }
    };
}

QVariant SettingsListModel::data(const QModelIndex &index, int role) const
{
    auto &model = _models[index.row()];

    switch (static_cast<Roles>(role)) {
    case Roles::Category:
        return model.category;
    case Roles::ID:
        return model.id;
    case Roles::Name:
        return model.name;
    case Roles::Help:
        return model.help;
    case Roles::Tags:
        return model.tags;
    case Roles::Type:
        return model.type;
    case Roles::CurrentValue:
        return model.currentValue;
    case Roles::Values:
        return model.values;
    default:
        return model.name;
    }
}

bool SettingsListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    auto &model = _models[index.row()];
    bool changed = false;

    switch (static_cast<Roles>(role)) {
        case Roles::CurrentValue:
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

bool SettingsListModel::read(const QString &values)
{
    auto valuesPath = values;
    if (values.isEmpty()) {
        valuesPath = LexoDefaultSettingsPath;

    }

    _jsonSettingsFile.setFileName(SettingsPath);
    _jsonValuesFile.setFileName(valuesPath);

    if (!_jsonSettingsFile.exists() || !_jsonSettingsFile.open(QIODevice::ReadOnly | QIODevice::Text))
        throw std::logic_error("SettingsListModel::read: No settings file");
    _jsonSettingsStr = _jsonSettingsFile.readAll();
    _jsonSettingsFile.close();

    if (_jsonValuesFile.exists() && _jsonValuesFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        _jsonValuesStr = _jsonValuesFile.readAll();
        _jsonValuesFile.close();
    }

    return true;
}

bool SettingsListModel::load(const QString &values) noexcept
{
    if (!read(values) || _jsonSettingsStr.isEmpty())
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

    _categories.clear();
    for (const auto &model : _models) {
        auto category = model.category;
        category.remove(0, 1);
        auto idx = category.indexOf('/');
        if (idx != -1)
            category.remove(idx, category.size() - idx);
        if (_categories.indexOf(category) == -1)
            _categories.append(category);
    }
    emit categoriesChanged();
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
    auto path = _jsonValuesFile.fileName();
    const auto idx = path.lastIndexOf('/');
    if (idx != -1)
        path.remove(idx, path.size() - idx);
    QDir().mkpath(path);
    if (!_jsonValuesFile.open(QIODevice::WriteOnly | QFile::Truncate)) {
        qDebug() << "SettingsListModel::saveValues: Couldn't open values file" << _jsonValuesFile.fileName();
        return false;
    }
    QVariantMap map;
    for (auto it = _models.begin(); it != _models.end(); it++) {
        if (it->type != "StringPairList")
            map.insert(it->id, it->currentValue);
        else {
            auto list = it->currentValue.toList();
            QJsonArray value;
            for (auto i = 0; i < list.size(); ++i) {
                QJsonArray pair;
                auto stringPair = list[i].toStringList();
                pair.append(stringPair[0]);
                pair.append(stringPair[1]);
                value.append(pair);
            }
            qDebug() << "Map" << value;
            map.insert(it->id, QVariant::fromValue(value));
        }
    }
    QJsonDocument doc(QJsonDocument::fromVariant(map));
    _jsonValuesFile.write(doc.toJson(QJsonDocument::Indented));
    _jsonValuesFile.close();
    return true;
}

bool SettingsListModel::set(const QString &id, const QVariant &value) noexcept
{
    auto i = 0;
    for (auto it = _models.begin(); it != _models.end(); it++) {
        if (it->id == id) {
            it->currentValue = value;
            emit dataChanged(index(i), index(i), { static_cast<int>(Roles::CurrentValue) });
            return true;
        }
        ++i;
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

QVariant SettingsListModel::getDefault(const QString &id, const QVariant &defaultValue) const noexcept
{
    for (auto it = _models.begin(); it != _models.end(); it++) {
        if (it->id == id)
            return it->currentValue;
    }
    return defaultValue;
}
