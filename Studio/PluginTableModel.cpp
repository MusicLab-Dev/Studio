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
        { static_cast<int>(Roles::Name), "factoryName" },
        { static_cast<int>(Roles::Description), "factoryDescription" },
        { static_cast<int>(Roles::Path), "factoryPath" },
        { static_cast<int>(Roles::SDK), "factorySdk" },
        { static_cast<int>(Roles::Tags), "factoryTags" }
    };
}


QVariant PluginTableModel::data(const QModelIndex &index, int role) const
{
    auto *factory = get(index.row());
    switch (static_cast<PluginTableModel::Roles>(role)) {
    case Roles::Name:
    {
        const auto name = factory->getName();
        return QString::fromLocal8Bit(name.data(), static_cast<int>(name.length()));
    }
    case Roles::Description:
    {
        const auto desc = factory->getDescription();
        return QString::fromLocal8Bit(desc.data(), static_cast<int>(desc.length()));
    }
    case Roles::Path:
    {
        const auto path = factory->getPath();
        return QString::fromLocal8Bit(path.data(), static_cast<int>(path.length()));
    }
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
        throw std::range_error("PluginTableModel::get: Given index is not in range: " + std::to_string(index) + " out of [0, " + std::to_string(count()) + "["));
    return _data.factories()[index].get();
}

void PluginTableModel::add(const QString &path)
{
    UNUSED(path);
    // beginInsertRows(QModelIndex(), count(), count());
    // _data.registerFactory(path.toStdString());
    // endInsertRows();
}

PluginTableModel::ExternalInputType PluginTableModel::getExternalInputType(const QString &path) const noexcept
{
    auto factory = _data.find(path.toStdString());
    if (factory) {
        const auto flags = static_cast<std::uint16_t>(factory->getFlags());
        if (flags & static_cast<std::uint16_t>(Audio::IPluginFactory::Flags::MultipleExternalInputs))
            return ExternalInputType::Multiple;
        else if (flags & static_cast<std::uint16_t>(Audio::IPluginFactory::Flags::SingleExternalInput))
            return ExternalInputType::Single;
    }
    return ExternalInputType::None;
}

