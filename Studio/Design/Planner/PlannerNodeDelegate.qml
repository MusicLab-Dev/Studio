import QtQuick 2.15

import NodeModel 1.0

import "../Default"

Item {
    property NodeModel node: nodeInstance.instance
    property bool isSelected: false
    property color color: nodeDelegate.node ? nodeDelegate.node.color : "black"
    property bool showChildren: false
    property var parentDelegate: null
    readonly property bool isChild: parentDelegate !== null

    id: nodeDelegate
    width: nodeDelegateCol.width
    height: nodeDelegateCol.height

    Rectangle {
        id: nodeHeaderBackground
        x: nodeDelegate.isChild ? contentView.rowHeaderWidth * 0.25 : 10
        y: 5
        width: contentView.rowHeaderWidth - x - 10
        height: (nodeDelegate.isSelected ? nodeControls.y + nodeControls.height : nodePartitions.height) - 5
        color: Qt.lighter(nodeDelegate.color, nodePartitions.headerPressed ? 1.25 : nodePartitions.headerHovered ? 1.15 : 1)
        radius: 15

        Rectangle {
            x: -width
            y: parent.height / 2 - 2
            width: contentView.rowHeaderWidth * (0.25 - 0.125)
            height: 4
            color: nodeDelegate.parentDelegate ? nodeDelegate.parentDelegate.color : "black"
            visible: nodeDelegate.isChild
        }
    }

    Rectangle {
        anchors.top: nodeHeaderBackground.bottom
        anchors.bottom: nodeDelegate.bottom
        anchors.bottomMargin: 5
        x: contentView.rowHeaderWidth * 0.125
        width: 4
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