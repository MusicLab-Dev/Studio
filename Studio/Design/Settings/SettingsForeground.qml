import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Rectangle {
    id: settingsForeground
    color: Qt.lighter(themeManager.foregroundColor, 1.2)
    radius: 6

    Rectangle {
        width: parent.width * 0.1
        height: parent.height
        anchors.right: parent.right
        color: parent.color
    }

    Item {
        id: settingsResearchTextInput
        width: parent.width * 0.8
        height : parent.height * 0.05
        x: (parent.width - width) / 2
        y: (parent.height - height) / 25

        DefaultTextInput {
            anchors.fill: parent
            placeholderText: qsTr("Research")
            color: "white"

            onTextChanged: {
                settingsContentArea.settingsProxyModel.tags = text
            }
        }
    }

    Column {
        height: parent.height - settingsResearchTextInput.height
        y: settingsResearchTextInput.y + settingsResearchTextInput.height * 1.5
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Repeater {
            model: app.settings.categories

            delegate: SettingsForegroundCard {

                onReleased: {
                    settingsContentArea.settingsProxyModel.category = modelData
                }

                Component.onCompleted: {
                    if (index === 0)
                        settingsContentArea.settingsProxyModel.category = modelData
                }
            }
        }
    }



}
