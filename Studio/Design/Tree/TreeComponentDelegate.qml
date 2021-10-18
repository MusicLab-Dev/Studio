import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0
import CursorManager 1.0

import "../Default"
import "../Common"

Item {
    property color color: "white"

    id: componentDelegate

    Component.onCompleted: {
        color = treeComponentsPanel.tagsToColor(treeComponentsPanel.filter)
    }

    MouseArea {
        id: instanceBackground
        width: componentDelegate.width * 0.7
        height: width * 1.3
        anchors.horizontalCenter: drag.active ? undefined : parent.horizontalCenter
        hoverEnabled: true
        drag.target: instanceBackground
        drag.smoothed: true
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        drag.onActiveChanged: {
            if (drag.active) {
                treeSurface.startPluginDrag(factoryPath, treeSurface.mapFromItem(instanceBackground, mouseX, mouseY))
                parent = contentView
            } else {
                treeSurface.endPluginDrag()
                parent = componentDelegate
                x = 0
                y = 0
            }
        }

        onHoveredChanged: {
            if (containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }

        Connections {
            enabled: instanceBackground.drag.active
            target: instanceBackground

            function onXChanged() {
                treeSurface.updateDrag(treeSurface.mapFromItem(instanceBackground, instanceBackground.mouseX, instanceBackground.mouseY))
            }

            function onYChanged() {
                treeSurface.updateDrag(treeSurface.mapFromItem(instanceBackground, instanceBackground.mouseX, instanceBackground.mouseY))
            }
        }

        Item {
            id: header
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 30

            Rectangle {
                anchors.fill: parent
                color: instanceBackground.containsMouse ? componentDelegate.color : themeManager.backgroundColor
                radius: 2
                opacity: 1
            }

            DefaultText {
                anchors.fill: parent
                text: factoryName
                color: instanceBackground.containsMouse ? themeManager.backgroundColor : componentDelegate.color
            }

        }

        Item {
            id: rect
            anchors.top: header.bottom
            anchors.topMargin: 3
            width: parent.width
            height: width

            Rectangle {
                anchors.fill: parent
                color: themeManager.backgroundColor
                radius: 2
                opacity: 1
            }

            PluginFactoryImage {
                id: image
                anchors.centerIn: parent
                width: parent.width * 0.5
                height: width
                name: factoryName
                playing: instanceBackground.containsMouse
                color: componentDelegate.color
            }
        }
    }

    Rectangle {
        anchors.top: instanceBackground.bottom
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        width: rect.width
        height: 2
        color: "black"
    }

    DefaultToolTip { // @todo make this a unique instance
        visible: instanceBackground.containsMouse || instanceBackground.containsPress
        text: factoryDescription
    }
}
