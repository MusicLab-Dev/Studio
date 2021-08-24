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
                x: 10
                width: parent.width * 0.5
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                fontSizeMode: Text.HorizontalFit
                font.pointSize: 28
                color: nodeDelegate.accentColor
                text: nodeDelegate.node ? nodeDelegate.node.name : qsTr("ERROR")
                wrapMode: Text.Wrap
            }

            DefaultImageButton {
                readonly property bool isMuted: nodeDelegate.node ? nodeDelegate.node.muted : false

                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: Math.min(parent.height / 2, 50)
                source: isMuted ? "qrc:/Assets/Muted.png" : "qrc:/Assets/Unmuted.png"
                showBorder: false
                scaleFactor: 1
                colorDefault: nodeDelegate.accentColor
                colorHovered: nodeDelegate.hoveredColor
                colorOnPressed: nodeDelegate.pressedColor

                onReleased: nodeDelegate.node.muted = !isMuted
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
