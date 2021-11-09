/**
 * @ Author: Cédric Lucchese
 * @ Description: Main AudioAPI header
 */

#include "AudioAPI.hpp"

ControlDescriptor AudioAPI::getControlDescriptor(PluginModel *plugin, const ParamID paramID) const noexcept
{
    constexpr auto ToQString = [](const std::string_view &str) {
        return QString::fromLocal8Bit(str.data(), static_cast<int>(str.size()));
    };

    const auto &meta = plugin->audioPlugin()->getMetaData();
    auto &ctrl = meta.controls[paramID];
    ControlDescriptor desc;
    desc.controlParamID = paramID; // ParamID
    desc.controlType = static_cast<PluginModel::ParamType>(ctrl.type); // ParamType
    desc.controlMinValue = ctrl.rangeValues.min; // ParamValue
    desc.controlMaxValue = ctrl.rangeValues.max; // ParamValue
    desc.controlStepValue = ctrl.rangeValues.step; // ParamValue
    desc.controlDefaultValue = ctrl.defaultValue; // ParamValue
    desc.controlTitle = ToQString(ctrl.translations.getName(Audio::English)); // QString
    desc.controlDescription = ToQString(ctrl.translations.getDescription(Audio::English)); // QString
    desc.controlShortName = ToQString(Audio::FindTranslation(ctrl.shortNames, Audio::English)); // QString
    desc.controlUnitName = ToQString(Audio::FindTranslation(ctrl.unitNames, Audio::English)); // QString
    {
        QVector<QString> ranges;
        ranges.reserve(ctrl.rangeNames.size());
        std::uint32_t i = 0u;
        for (auto &elem : ranges) {
            elem = ToQString(Audio::FindTranslation(ctrl.rangeNames[i], Audio::English));
            ++i;
        }
        desc.controlRangeNames = std::move(ranges); // QVector<QString>
    }
    return desc;
}
