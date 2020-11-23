/**
 * @ Author: Cédric Lucchese
 * @ Description: Device Model implementation
 */

#include <stdexcept>

#include <QQmlEngine>

#include "DeviceModel.hpp"

DeviceModel::DeviceModel(QObject *parent) noexcept
    : QAbstractListModel(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> DeviceModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { Roles::Name, "name" },
        { Roles::IsInput, "isInput" }
    };
}

QVariant DeviceModel::data(const QModelIndex &index, int role) const noexcept_ndebug
{
    coreAssert(index.row() < 0 || index.row() >= count(),
        throw std::range_error("InstancesModel::data: Given index is not in range"));
    const auto &child = (*_data)[index.row()];
    switch (role) {
    case Roles::Name:
        return child.name();
    case Roles::IsInput:
        return child.isInput();
    default:
        return QVariant();
    }
}

DeviceModel::DevicePtr DeviceModel::instantiate(const QString &name)
{
    /** TODO */
}