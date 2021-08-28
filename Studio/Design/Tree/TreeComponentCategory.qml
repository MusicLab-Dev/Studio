import QtQuick 2.0
import QtQuick.Layouts 1.3

import "../Default"

import CursorManager 1.0

Rectangle {
    property alias mouseArea: mouse
    property alias text: text

    property int filter: 0
    property int tags: 0

    width: parent.width
    height: panelCategoryHeight
    color: treeComponentsPanel.filter === filter ? Qt.darker(themeManager.foregroundColor, 1.1) : mouseArea.containsMouse ? themeManager.accentColor : Qt.lighter(themeManager.foregroundColor, 1.2)

    DefaultText {
        id: text
        anchors.fill: parent
        font.pixelSize: 20
        fontSizeMode: Text.Fit
        text: ""
        color: treeComponentsPanel.filter === filter ? themeManager.accentColor : mouseArea.containsMouse ? Qt.darker(themeManager.foregroundColor, 1.1) : "white"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true

        onHoveredChanged: {
            if (containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }

        onPressed: {
            open(filter)
        }
    }

}
