import QtQuick 2.15

import "../Default"

import PartitionsModel 1.0
import PartitionInstancesModel 1.0

Row {
    readonly property PartitionsModel partitions: nodeDelegate.node ? nodeDelegate.node.partitions : null
    readonly property PartitionInstancesModel instances: partitions ? partitions.instances : null

    id: nodeInstances

    Item {
        id: nodeInstancesHeader
        width: contentView.rowHeaderWidth
        height: contentView.rowHeight

        Item {
            id: nodeInstancesBackground
            x: nodeHeaderBackground.x
            y: nodeHeaderBackground.y
            width: nodeHeaderBackground.width
            height: nodeInstancesHeader.height

            DefaultText {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 16
                color: nodeDelegate.isSelected ? themeManager.backgroundColor : nodeDelegate.color
                text: nodeDelegate.node ? nodeDelegate.node.name : qsTr("ERROR")
                elide: Text.ElideRight
            }
        }
    }

    Item {
        width: contentView.rowDataWidth
        height: contentView.rowHeight
        clip: true

        PlannerNodeInstancesRow {
            id: instancesView
            width: contentView.rowDataWidth
            height: contentView.rowHeight
        }

        PlannerNodeInstancesPlacementArea {
            id: placementView
            width: contentView.rowDataWidth
            height: contentView.rowHeight
        }
    }
}
