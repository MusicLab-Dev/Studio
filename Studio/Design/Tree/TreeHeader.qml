import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Rectangle {
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    Item {
        anchors.fill: parent

        DefaultText {
            anchors.fill: parent
            text: app.project.name
            color: "white"
            font.pixelSize: 35
        }
    }
}
