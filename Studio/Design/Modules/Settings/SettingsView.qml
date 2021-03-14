import QtQuick 2.15
import QtQuick.Controls 2.15

SettingsBackground {
    id: settingsView

    SettingsViewTitle {
        id: settingsViewTitle
        x: (settingsForeground.width + (parent.width - settingsForeground.width) / 2) - width / 2
        y: height
    }

    SettingsForeground {
        id: settingsForeground
        x: parent.parent.x
        y: parent.parent.y
        width: Math.max(parent.width * 0.2, 350)
        height: parent.height
    }

    SettingsContentArea {
        id: settingsContentArea
        anchors.top: settingsViewTitle.bottom
        anchors.left: settingsForeground.right
        anchors.right: settingsView.right
        anchors.bottom: settingsView.bottom
        anchors.margins: parent.width * 0.05
    }
}
