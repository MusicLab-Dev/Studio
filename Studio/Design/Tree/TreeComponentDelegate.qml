import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0

import "../Default"
import "../Common"

Item {
    id: componentDelegate

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

        Rectangle {
            id: rect
            anchors.fill: parent
            color: "transparent"
            border.width: 2
            border.color: instanceBackground.containsPress ? Qt.lighter(themeManager.contentColor, 1.2) : instanceBackground.containsMouse ? themeManager.accentColor : "white"
            radius: 12
        }

        PluginFactoryImageButton {
            id: image
            name: factoryName
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: width
        }

        Glow {
            anchors.fill: image
            radius: 2
            opacity: 0.3
            samples: 17
            color: instanceBackground.containsMouse ? "white" : "transparent"
            source: image
        }
    }

    DefaultText {
        anchors.top: instanceBackground.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        text: factoryName
        color: instanceBackground.containsMouse ? themeManager.accentColor : "white"
    }

    DefaultToolTip { // @todo make this a unique instance
        visible: instanceBackground.containsMouse || instanceBackground.containsPress
        text: factoryDescription
    }
}
