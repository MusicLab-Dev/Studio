import QtQuick 2.15

import NodeModel 1.0

import "../Default"
import "../Common"
import "../Help"

Item {
    property NodeModel node: nodeInstance.instance
    property bool showChildren: false
    property var parentDelegate: null
    readonly property bool isChild: parentDelegate !== null

    // Selection
    property bool isSelected: false
    property bool isLastSelected: nodeDelegate == contentView.lastSelectedNode

    // Colors
    readonly property color color: nodeDelegate.node ? nodeDelegate.node.color : "black"
    readonly property color darkColor: Qt.darker(color, 1.25)
    readonly property color lightColor: Qt.lighter(color, 1.6)
    readonly property color hoveredColor: Qt.darker(color, 1.8)
    readonly property color pressedColor: Qt.darker(color, 2.2)
    readonly property color accentColor: Qt.darker(color, 1.6)

    // Alias
    readonly property alias nodeHeaderBackground: nodeHeaderBackground

    id: nodeDelegate
    width: nodeDelegateCol.width
    height: nodeDelegateCol.height

    SoundMeter {
        id: soundMeter
        enabled: plannerView.visible
        targetNode: nodeDelegate.node
        width: height / 5
        height: nodeHeaderBackground.height
        anchors.left: nodeHeaderBackground.right
        anchors.top: nodeHeaderBackground.top
        anchors.leftMargin: 5
    }

    Rectangle {
        id: nodeHeaderBackground
        x: nodeDelegate.isChild ? contentView.childOffset : contentView.headerMargin
        y: contentView.headerHalfMargin
        width: contentView.rowHeaderWidth - x - contentView.headerMargin - soundMeter.width - 12
        height: (nodeDelegate.isSelected ? nodeControls.y + nodeControls.height : nodeInstances.height) - contentView.headerHalfMargin
        radius: 15
        color: nodeDelegate.color
        border.color: nodeHeaderMouseArea.containsPress ? nodeDelegate.pressedColor : nodeDelegate.isLastSelected ? nodeDelegate.lightColor : nodeDelegate.hoveredColor
        border.width: nodeHeaderMouseArea.containsMouse || nodeDelegate.isLastSelected ? 4 : 0

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
                }
            }

            onClicked: {
                if (mouse.button !== Qt.RightButton) {
                    if (isLastSelected) {
                        nodeDelegate.isSelected = !nodeDelegate.isSelected
                        if (!nodeDelegate.isSelected)
                            contentView.lastSelectedNode = null
                    } else {
                        nodeDelegate.isSelected = true
                        contentView.lastSelectedNode = nodeDelegate
                    }
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

        PlannerNodeInstances {
            id: nodeInstances
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
