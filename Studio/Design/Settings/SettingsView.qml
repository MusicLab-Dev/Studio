import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Common"

Item {

    function open(multiplePath, accepted, canceled) {
        visible = true
        openAnim.restart()
    }

    function close() {
        visible = false
    }

    id: settingsView
    visible: false

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: settingsWindow; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: shadow; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: background; property: "opacity"; from: 0.1; to: 0.5; duration: 300; easing.type: Easing.Linear }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: themeManager.backgroundColor
        opacity: 0.5
    }

    DropShadow {
        id: shadow
        anchors.fill: settingsWindow
        horizontalOffset: 4
        verticalOffset: 4
        radius: 6
        samples: 17
        color: "#80000000"
        source: settingsWindow
    }

    ContentPopup {
        id: settingsWindow

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
                filled: true

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
