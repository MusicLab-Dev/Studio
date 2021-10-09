import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0

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
        height: width * 1.1
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
            id: rect
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: themeManager.backgroundColor
                border.color: instanceBackground.containsMouse ? componentDelegate.color : "white"
                radius: width / 4
            }

            PluginFactoryImage {
                id: image
                width: parent.width / 1.5
                height: width
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2
                name: factoryName
                playing: instanceBackground.containsMouse
                color: panelContentBackground.color
            }
        }
    }

    DefaultText {
        anchors.top: instanceBackground.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        text: factoryName
        color: instanceBackground.containsMouse ? componentDelegate.color : "white"
    }

    DefaultToolTip { // @todo make this a unique instance
        visible: instanceBackground.containsMouse || instanceBackground.containsPress
        text: factoryDescription
    }
}
