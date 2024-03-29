import QtQuick 2.15

import NodeModel 1.0
import CursorManager 1.0

import "../Default"
import "../Common"

Item {
    function selectAutomation(index) {
        nodeInstances.selectAutomation(index)
    }

    function hideAutomations(index) {
        nodeInstances.hideAutomations()
    }

    property NodeModel node: nodeInstance.instance
    property bool showChildren: false
    property var parentDelegate: null
    readonly property bool isChild: parentDelegate !== null
    readonly property int selectedAutomation: nodeInstances.selectedAutomation
    readonly property bool showAutomations: nodeInstances.showAutomations

    // Selection
    property bool isSelected: nodeDelegate == contentView.selectedNode

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
        width: contentView.rowHeaderWidth * 0.125
        height: nodeHeaderBackground.height
        anchors.left: nodeHeaderBackground.right
        anchors.top: nodeHeaderBackground.top
        anchors.leftMargin: 5

        onMutedChanged: nodeDelegate.node.muted = muted
    }

    Rectangle {
        id: nodeHeaderBackground
        x: nodeDelegate.isChild ? contentView.childOffset : contentView.headerMargin
        y: contentView.headerHalfMargin
        width: contentView.rowHeaderWidth - x - contentView.headerMargin - soundMeter.width - 12
        height: nodeInstances.height - contentView.headerHalfMargin
        radius: 2
        color: nodeDelegate.isSelected ? nodeDelegate.color : themeManager.foregroundColor
        border.color: nodeDelegate.color
        border.width: nodeHeaderMouseArea.containsMouse ? 2 : 0

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
                    if (!nodeDelegate.isSelected)
                        contentView.selectedNode = nodeDelegate
                    else
                        contentView.selectedNode = null
                }
            }

            onPressAndHold: {
                plannerNodeMenu.openMenu(nodeDelegate, nodeDelegate.node)
                plannerNodeMenu.x = mouse.x
                plannerNodeMenu.y = mouse.y
            }

            onHoveredChanged: {
                onHoveredChanged: {
                    if (containsMouse)
                        cursorManager.set(CursorManager.Type.Clickable)
                    else
                        cursorManager.set(CursorManager.Type.Normal)
                }
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

        PlannerNodeAutomations {
            id: nodeAutomations
        }

        Rectangle {
            width: contentView.rowDataWidth
            height: 1
            x: contentView.rowHeaderWidth
            color: "white"
            opacity: 0.3
        }

        PlannerNodeChildren {
            id: nodeChildren
        }
    }
}
