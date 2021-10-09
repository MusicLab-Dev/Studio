import QtQuick 2.15

import "../Default"

Rectangle {
    property real barSize: width / 4

    id: newTabButton
    color: themeManager.backgroundColor
    border.color: "black"

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onReleased: modulesView.addNewSequencer()
    }

    Rectangle {
        id: barHorizontal
        width: barSize
        height: 2
        anchors.centerIn: parent
        radius: 8
        color: mouseArea.containsPress ? themeManager.accentColor : mouseArea.containsMouse ? themeManager.semiAccentColor : "white"
    }

    Rectangle {
        width: 2
        height: barSize
        anchors.centerIn: parent
        radius: 8
        color: barHorizontal.color

    }
}
