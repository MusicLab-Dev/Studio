import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

SettingsBackground {
    id: settingsView
    visible: false
    padding: 0

    Item {
        width: parent.width
        height: parent.height

        SettingsTitle {
            id: settingsTitle
            x: (settingsForeground.width + (parent.width - settingsForeground.width) / 2) - width / 2
            y: height

        }

        TextRoundedButton {
            id: settingsViewDefaultsButtonText
            text: qsTr("Defaults")
            y: height
            anchors.right: settingsViewReloadButtonText.left
            anchors.rightMargin: height

            onReleased: app.settings.resetDefaults()
        }

        TextRoundedButton {
            id: settingsViewReloadButtonText
            text: qsTr("Reload")
            y: height
            width: settingsViewDefaultsButtonText.width
            height: settingsViewDefaultsButtonText.height
            anchors.right: settingsViewCloseButtonText.left
            anchors.rightMargin: height

            onReleased: app.settings.reload()
        }

        TextRoundedButton {
            id: settingsViewCloseButtonText
            x: parent.width - width - height
            y: height
            width: settingsViewDefaultsButtonText.width
            height: settingsViewDefaultsButtonText.height
            text: qsTr("Done")

            onReleased: {
                app.settings.saveValues()
                settingsView.close()
            }
        }

        SettingsForeground {
            id: settingsForeground
            width: Math.max(parent.width * 0.2, 350)
            height: parent.height
        }

        SettingsContentArea {
            id: settingsContentArea
            anchors.left: settingsForeground.right
            anchors.right: parent.right
            anchors.top: settingsTitle.bottom
            anchors.bottom: parent.bottom
            anchors.margins: parent.width * 0.05
        }
    }
}
