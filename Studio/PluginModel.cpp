/**
 * @ Author: Cédric Lucchese
 * @ Description: PluginModel class
 */

#include <QQmlEngine>

#include "PluginModel.hpp"

PluginModel::PluginModel(Audio::IPlugin *plugin, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(plugin)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PluginModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Value), "controlValue"},
        { static_cast<int>(Roles::Title), "controlTitle"},
        { static_cast<int>(Roles::Description), "controlDescription"},
    };
}

QVariant PluginModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("PartitionModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    auto child = _data->getControl(index.row());
    const auto &meta = _data->getMetaData().controls[index.row()].translations;
    const QString title = QString::fromLocal8Bit(meta.getName(Audio::English).data(), meta.getName(Audio::English).size());
    const QString description = QString::fromLocal8Bit(meta.getDescription(Audio::English).data(), meta.getDescription(Audio::English).size());
    switch (static_cast<Roles>(role)) {
        case Roles::Value:
            return child;
        case Roles::Title:
            return title;
        case Roles::Description:
            return description;
        default:
            return QVariant();
    }
}

