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
        color: Qt.lighter(nodeDelegate.color, nodePartitions.headerPressed ? 1.25 : nodePartitions.headerHovered ? 1.15 : 1)
        radius: 15

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