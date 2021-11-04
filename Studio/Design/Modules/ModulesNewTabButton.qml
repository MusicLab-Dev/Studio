import QtQuick 2.15

import CursorManager 1.0

import "../Default"

Rectangle {
    property real barSize: width / 4

    id: newTabButton
    color: mouseArea.containsMouse ? themeManager.foregroundColor : themeManager.contentColor

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onReleased: modulesView.addNewSequencer()

        onHoveredChanged: {
            if (containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }
    }

    Rectangle {
        id: barHorizontal
        width: barSize
        height: 2
        anchors.centerIn: parent
        radius: 6
        color: mouseArea.containsPress ? themeManager.accentColor : mouseArea.containsMouse ? themeManager.semiAccentColor : "white"
    }

    Rectangle {
        width: 2
        height: barSize
        anchors.centerIn: parent
        radius: 6
        color: barHorizontal.color

    }
}
