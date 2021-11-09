import QtQuick 2.0

import CursorManager 1.0
import ThemeManager 1.0

import "../Default"
import "../Common"

Item {
    property alias mouseArea: mouseArea
    property alias iconSource: icon.source
    property alias toolTipText: toolTip.text

    Rectangle {
        id: rectButton
        anchors.fill: parent
        radius: 6
        color: sequencerView.node && mouseArea.containsMouse ? sequencerView.node.color : themeManager.contentColor

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onHoveredChanged: {
                if (containsMouse)
                    cursorManager.set(CursorManager.Type.Clickable)
                else
                    cursorManager.set(CursorManager.Type.Normal)
            }
        }

        DefaultColoredImage {
            id: icon
            anchors.fill: parent
            anchors.margins: parent.width * 0.25
            color: mouseArea.containsMouse ? themeManager.contentColor : sequencerView.node ? sequencerView.node.color : "black"
        }
    }

    DefaultToolTip {
        id: toolTip
        visible: mouseArea.containsMouse
    }
}
