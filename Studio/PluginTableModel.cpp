/**
 * @ Author: Cédric Lucchese
 * @ Description: Plugin Table Model implementation
 */

#include <stdexcept>

#include <QQmlEngine>

#include "PluginTableModel.hpp"

PluginTableModel::PluginTableModel(QObject *parent) noexcept
    : QAbstractListModel(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PluginTableModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Name), "name" },
        { static_cast<int>(Roles::Path), "path" },
        { static_cast<int>(Roles::SDK), "sdk" },
        { static_cast<int>(Roles::Tags), "tags" }
    };
}


QVariant PluginTableModel::data(const QModelIndex &index, int role) const
{
    auto *factory = get(index.row());
    switch (static_cast<PluginTableModel::Roles>(role)) {
    case Roles::Name:
        return QString(factory->getName().data());
    case Roles::Path:
        return QString(factory->getPath().data());
    case Roles::SDK:
        return static_cast<std::uint32_t>(factory->getSDK());
    case Roles::Tags:
        return static_cast<std::uint32_t>(factory->getTags());
    default:
        return QVariant();
    }
}

Audio::IPluginFactory *PluginTableModel::get(const int index) const noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::out_of_range("PluginTableModel::get: Invalid index " + std::to_string(index)));
    return _data.factories()[index].get();
}

void PluginTableModel::add(const QString &path)
{
    beginInsertRows(QModelIndex(), count(), count());
    _data.registerFactory(path.toStdString());
    endInsertRows();
}
