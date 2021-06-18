import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

SettingsCategoryButton {
    id: settingsForegroundCard
    width: settingsForeground.width * 0.9
    height: (settingsForeground.height - settingsResearchTextInput.height) / 8 * 0.8
    text: modelData
    iconSource: "qrc:/Assets/Settings/" + modelData + ".png"
}