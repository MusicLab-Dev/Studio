/**
 * @ Author: Cédric Lucchese
 * @ Description: PluginModel class
 */

#include <QQmlEngine>

#include "PluginModel.hpp"
#include "Models.hpp"

PluginModel::PluginModel(Audio::IPlugin *plugin, QObject *parent) noexcept
    : QAbstractListModel(parent), _data(plugin)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::ObjectOwnership::CppOwnership);
}

QHash<int, QByteArray> PluginModel::roleNames(void) const noexcept
{
    return QHash<int, QByteArray> {
        { static_cast<int>(Roles::ParamID), "controlParamID"},
        { static_cast<int>(Roles::Type), "controlType"},
        { static_cast<int>(Roles::MinValue), "controlMinValue"},
        { static_cast<int>(Roles::MaxValue), "controlMaxValue"},
        { static_cast<int>(Roles::StepValue), "controlStepValue"},
        { static_cast<int>(Roles::DefaultValue), "controlDefaultValue"},
        { static_cast<int>(Roles::Value), "controlValue"},
        { static_cast<int>(Roles::RangeNames), "controlRangeNames"},
        { static_cast<int>(Roles::Title), "controlTitle"},
        { static_cast<int>(Roles::Description), "controlDescription"},
        { static_cast<int>(Roles::ShortName), "controlShortName"},
        { static_cast<int>(Roles::UnitName), "controlUnitName"},
    };
}

QVariant PluginModel::data(const QModelIndex &index, int role) const
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("PartitionModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    const auto &meta = _data->getMetaData().controls[index.row()];
    switch (static_cast<Roles>(role)) {
        case Roles::ParamID:
            return index.row();
        case Roles::Type:
            return static_cast<int>(meta.type);
        case Roles::MinValue:
            return meta.rangeValues.min;
        case Roles::MaxValue:
            return meta.rangeValues.max;
        case Roles::StepValue:
            return meta.rangeValues.step;
        case Roles::DefaultValue:
            return meta.defaultValue;
        case Roles::Value:
            return _data->getControl(index.row());
        case Roles::RangeNames:
        {
            QStringList list;
            for (const auto &it : meta.rangeNames) {
                const auto &cache = Audio::FindTranslation(it, Audio::English);
                list.append(QString::fromLocal8Bit(cache.data(), static_cast<int>(cache.size())));
            }
            return list;
        }
        case Roles::Title:
        {
            const auto &cache = meta.translations.getName(Audio::English);
            return QString::fromLocal8Bit(cache.data(), static_cast<int>(cache.size()));
        }
        case Roles::Description:
        {
            const auto &cache = meta.translations.getDescription(Audio::English);
            return QString::fromLocal8Bit(cache.data(), static_cast<int>(cache.size()));
        }
        case Roles::ShortName:
        {
            const auto &cache = Audio::FindTranslation(meta.shortNames, Audio::English);
            return QString::fromLocal8Bit(cache.data(), static_cast<int>(cache.size()));
        }
        case Roles::UnitName:
        {
            const auto &cache = Audio::FindTranslation(meta.unitNames, Audio::English);
            return QString::fromLocal8Bit(cache.data(), static_cast<int>(cache.size()));
        }
        default:
            return QVariant();
    }
}

bool PluginModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    coreAssert(index.row() >= 0 && index.row() < count(),
        throw std::range_error("PartitionModel::data: Given index is not in range: " + std::to_string(index.row()) + " out of [0, " + std::to_string(count()) + "["));
    switch (static_cast<Roles>(role)) {
        case Roles::Value:
            setControl(ControlEvent(index.row(), value.toDouble()));
            break;
        default:
            return false;
    }
    return true;
}

void PluginModel::setControl(const ControlEvent &event)
{
    Scheduler::Get()->addEvent(
        [this, event] {
            _data->getControl(event.paramID) = event.value;
        },
        [this, paramID = event.paramID] {
            processControlValueChanged(paramID);
        }
    );
}

QString PluginModel::getControlName(const ParamID paramID) const noexcept
{
    auto str = _data->getMetaData().controls[paramID].translations.getName(Audio::English);

    return QString::fromLocal8Bit(str.data(), static_cast<int>(str.length()));
}

void PluginModel::processControlValueChanged(const ParamID paramID)
{
    const auto modelIndex = index(paramID);
    emit dataChanged(modelIndex, modelIndex, { static_cast<int>(Roles::Value) });
    emit controlValueChanged(paramID);
}

QString PluginModel::title(void) const noexcept
{
    const auto &cache = _data->getMetaData().translations.getName(Audio::English);
    return QString::fromLocal8Bit(cache.data(), static_cast<int>(cache.size()));
}

QString PluginModel::description(void) const noexcept
{
    const auto &cache = _data->getMetaData().translations.getName(Audio::English);
    return QString::fromLocal8Bit(cache.data(), static_cast<int>(cache.size()));
}

QString PluginModel::path(void) const noexcept
{
    return audioPlugin()->factory()->getPath().data();
}

void PluginModel::setExternalInputs(const QVector<QString> &paths)
{
    Audio::ExternalPaths externals;
    externals.reserve(static_cast<std::uint32_t>(paths.size()));
    for (auto &path : paths) {
        externals.push(path.toStdString());
    }
    audioPlugin()->setExternalPaths(externals);
}
