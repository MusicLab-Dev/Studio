/**
 * @ Author: Cédric Lucchese
 * @ Description: Plugin Table Model implementation
 */

#include <stdexcept>

#include <QQmlEngine>

#include "PluginTableModel.hpp"

PluginTableModel::PluginTableModel(QObject *parent) noexcept
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PluginTableModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { Roles::Name, "name" },
        { Roles::Path, "path" },
        { Roles::SDK, "sdk" },
        { Roles::Tags, "tags" }
    };
}

QVariant PluginTableModel::data(const QModelIndex &index, int role) const noexcept_ndebug
{
    const auto *factory = get();
    switch (role) {
    case Roles::Name:
        return factory->name();
    case Roles::Path:
        return factory->path();
    case Roles::SDK:
        return factory->sdk();
    case Roles::Tags:
        return factory->tags();
    default:
        return QVariant();
    }
}

Audio::IPluginFactory *PluginTableModel::get(const int index) noexcept_ndebug
{
    coreAssert(index >= 0 && index < count(),
        throw std::out_of_range("PluginTableModel::get: Invalid index " + std::to_string(index)));
    return _data.factories()[index].get();
}

int PluginTableModel::add(const QString &path)
{
    /** TODO */
}

void PluginTableModel::remove(const int index)
{
    /** TODO */
}
