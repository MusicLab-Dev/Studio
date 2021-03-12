/**
 * @ Author: Cédric Lucchese
 * @ Description: Devices Model implementation
 */

#include <stdexcept>

#include <QQmlEngine>

#include "DevicesModel.hpp"

DevicesModel::DevicesModel(QObject *parent) noexcept
    : QAbstractListModel(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> DevicesModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Name), "name" },
        { static_cast<int>(Roles::IsInput), "isInput" }
    };
}

QVariant DevicesModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() < 0 || index.row() >= count(),
        throw std::range_error("InstancesModel::data: Given index is not in range"));
    const auto &child = (*_data)[index.row()];
    switch (static_cast<DevicesModel::Roles>(role)) {
    case Roles::Name:
        return child.name();
    case Roles::IsInput:
        return child.isInput();
    default:
        return QVariant();
    }
}

DevicesModel::DevicePtr DevicesModel::instantiate(const QString &name)
{
    Audio::Device dev;
    dev.
    /** TODO */
}