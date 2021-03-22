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
        { static_cast<int>(Roles::Value), "value"},
        { static_cast<int>(Roles::Title), "Title"},
        { static_cast<int>(Roles::Description), "Description"},
    };
}

QVariant PluginModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("PartitionModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    auto child = _data->getControl(index.row());
    const auto &meta = _data->getMetaData().controls[index.row()].translations;
    const QString &title = QString::fromLocal8Bit(meta.names[0].text.data(), meta.names[0].text.size());
    const QString &description = QString::fromLocal8Bit(meta.descriptions[0].text.data(), meta.descriptions[0].text.size());
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