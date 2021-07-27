import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0

import "../Default"

Item {
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width * 0.7
    height: width * 1.1

    Rectangle {
        id: rect
        width: parent.width
        height: width
        color: "transparent"
        border.width: 2
        border.color: mouseArea.containsMouse ? themeManager.accentColor : "white"
        radius: 12

            Image {
                id: image
                anchors.centerIn: parent
                width: parent.width * 0.7
                height: width
                source: factoryName ? "qrc:/Assets/Plugins/" + factoryName + ".png" : "qrc:/Assets/Plugins/Default.png"
            }

            Glow {
                anchors.fill: image
                radius: 2
                opacity: 0.3
                samples: 17
                color: mouseArea.containsMouse ? "white" : "transparent"
                source: image
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true


            }
        }

    DefaultText {
        anchors.top: rect.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        text: factoryName
        color: mouseArea.containsMouse ? themeManager.accentColor : "white"
    }


}
