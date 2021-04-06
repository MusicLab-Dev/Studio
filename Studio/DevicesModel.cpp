/**
 * @ Author: Cédric Lucchese
 * @ Description: Devices Model implementation
 */

#include <stdexcept>

#include <QQmlEngine>

#include "DevicesModel.hpp"

DevicesModel::DevicesModel(QObject *parent) noexcept
    : QAbstractListModel(parent), _descriptors(Audio::Device::GetPhysicalDescriptors())
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> DevicesModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::Name), "name" },
        { static_cast<int>(Roles::HasInput), "hasInput" },
        { static_cast<int>(Roles::HasOutput), "hasOutput" }
    };
}

QVariant DevicesModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 || index.row() < count(),
        throw std::range_error("DevicesModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    const auto &child = _descriptors.at(index.row());
    switch (static_cast<DevicesModel::Roles>(role)) {
    case Roles::Name:
        return child.name.c_str();
    case Roles::HasInput:
        return child.hasInput;
    case Roles::HasOutput:
        return child.hasOutput;
    default:
        return QVariant();
    }
    return QVariant();
}

/*
DevicesModel::DevicePtr DevicesModel::instantiate(const QString &name)
{
    Audio::Device dev;
    dev.
    TODO
}*/