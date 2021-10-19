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
    height: delegateColumn.height

    Component.onCompleted: {
        color = treeComponentsPanel.tagsToColor(treeComponentsPanel.filter)
    }

    DefaultToolTip { // @todo make this a unique instance
        visible: !delegateMouseArea.drag.active && (delegateMouseArea.containsMouse || delegateMouseArea.containsPress)
        text: factoryDescription
    }

    Column {
        id: delegateColumn
        spacing: 3

        Rectangle {
            id: header
            width: componentDelegate.width
            height: componentDelegate.width * 0.2
            color: delegateMouseArea.containsMouse ? componentDelegate.color : themeManager.backgroundColor
            radius: 2

            DefaultText {
                anchors.fill: parent
                text: factoryName
                color: delegateMouseArea.containsMouse ? themeManager.backgroundColor : componentDelegate.color
            }
        }


        MouseArea {
            id: delegateMouseArea
            width: componentDelegate.width
            height: componentDelegate.width
            hoverEnabled: true
            drag.target: delegateColumn
            drag.smoothed: true
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2

            drag.onActiveChanged: {
                if (drag.active) {
                    treeSurface.startPluginDrag(factoryPath, treeSurface.mapFromItem(delegateMouseArea, mouseX, mouseY))
                    delegateColumn.parent = contentView
                } else {
                    treeSurface.endPluginDrag()
                    delegateColumn.parent = componentDelegate
                    delegateColumn.x = 0
                    delegateColumn.y = 0
                }
            }

            onHoveredChanged: {
                if (containsMouse)
                    cursorManager.set(CursorManager.Type.Clickable)
                else
                    cursorManager.set(CursorManager.Type.Normal)
            }

            Rectangle {
                id: rect
                anchors.fill: parent
                color: themeManager.backgroundColor
                radius: 2

                PluginFactoryImage {
                    id: image
                    anchors.centerIn: parent
                    width: parent.width / 1.5
                    height: width
                    name: factoryName
                    playing: delegateMouseArea.containsMouse
                    color: componentDelegate.color
                }
            }

            Connections {
                enabled: delegateMouseArea.drag.active
                target: delegateColumn

                function onXChanged() {
                    treeSurface.updateDrag(treeSurface.mapFromItem(delegateMouseArea, delegateMouseArea.mouseX, delegateMouseArea.mouseY))
                }

                function onYChanged() {
                    treeSurface.updateDrag(treeSurface.mapFromItem(delegateMouseArea, delegateMouseArea.mouseX, delegateMouseArea.mouseY))
                }
            }
        }
    }
}
