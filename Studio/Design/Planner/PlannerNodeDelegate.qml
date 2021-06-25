import QtQuick 2.15

import NodeModel 1.0

import "../Default"

Item {
    property NodeModel node: nodeInstance.instance
    property bool isSelected: false
    property color color: nodeDelegate.node ? nodeDelegate.node.color : "black"
    property color hoveredColor: Qt.darker(color, 1.8)
    property color pressedColor: Qt.darker(color, 2.2)
    property color accentColor: Qt.darker(color, 1.6)
    property bool showChildren: false
    property var parentDelegate: null
    readonly property bool isChild: parentDelegate !== null
    property alias nodeHeaderBackground: nodeHeaderBackground

    id: nodeDelegate
    width: nodeDelegateCol.width
    height: nodeDelegateCol.height

    Rectangle {
        id: nodeHeaderBackground
        x: nodeDelegate.isChild ? contentView.childOffset : contentView.headerMargin
        y: contentView.headerHalfMargin
        width: contentView.rowHeaderWidth - x - contentView.headerMargin
        height: (nodeDelegate.isSelected ? nodeControls.y + nodeControls.height : nodePartitions.height) - contentView.headerHalfMargin
        radius: 15
        color: nodeDelegate.color
        border.color: nodeHeaderMouseArea.containsPress ? nodeDelegate.pressedColor : nodeDelegate.hoveredColor
        border.width: nodeHeaderMouseArea.containsMouse ? 4 : 0

        MouseArea {
            id: nodeHeaderMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: {
                if (mouse.button === Qt.RightButton) {
                    plannerNodeMenu.openMenu(nodeDelegate, nodeDelegate.node)
                    plannerNodeMenu.x = mouse.x
                    plannerNodeMenu.y = mouse.y
                } else {
                    nodeDelegate.isSelected = !nodeDelegate.isSelected
                }
            }

            onPressAndHold: {
                plannerNodeMenu.openMenu(nodeDelegate, nodeDelegate.node)
                plannerNodeMenu.x = mouse.x
                plannerNodeMenu.y = mouse.y
            }
        }

        Rectangle {
            x: -width
            y: parent.height / 2 - contentView.linkHalfThickness
            width: contentView.linkChildWidth
            height: contentView.linkThickness
            color: nodeDelegate.parentDelegate ? nodeDelegate.parentDelegate.color : "black"
            visible: nodeDelegate.isChild
        }
    }

    Rectangle {
        x: nodeDelegate.isChild ? contentView.linkChildOffset : contentView.linkOffset
        y: nodeHeaderBackground.y + nodeHeaderBackground.height
        width: contentView.linkThickness
        height: (nodeChildren.linkBottom !== 0 ? nodeChildren.linkBottom : nodeAutomations.linkBottom) - y
        color: nodeDelegate.color
    }

    Column {
        id: nodeDelegateCol

        PlannerNodePartitions {
            id: nodePartitions
        }

        PlannerRowDataLine {}

        PlannerNodeControls {
            id: nodeControls
            visible: nodeDelegate.isSelected
        }

        PlannerRowDataLine {}

        PlannerNodeAutomations {
            id: nodeAutomations
        }

        PlannerNodeChildren {
            id: nodeChildren
        }
    }
}