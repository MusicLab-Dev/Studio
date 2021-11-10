import QtQuick 2.15

import "../Default"

import PartitionInstancesModel 1.0
import PartitionInstancesModelProxy 1.0
import PartitionPreview 1.0
import PartitionModel 1.0
import AudioAPI 1.0

Item {
    Repeater {
        model: PartitionInstancesModelProxy {
            range: contentView.displayRange
            sourceModel: nodeInstances.instances
        }

        delegate: Item {
            property var instanceRange: range
            readonly property int targetPartitionIndex: partitionIndex
            property PartitionModel partition: nodeInstances.partitions.getPartition(targetPartitionIndex)

            id: instanceDelegate
            x: contentView.xOffset + instanceRange.from * contentView.pixelsPerBeatPrecision
            width: (instanceRange.to - instanceRange.from) * contentView.pixelsPerBeatPrecision
            height: contentView.rowHeight

            Rectangle {
                id: header
                width: parent.width
                height: parent.height * 0.2
                anchors.top: parent.top
                color: nodeDelegate.color
                border.color: nodeDelegate.accentColor
                border.width: 1
                radius: 2
                opacity: 0.8

                DefaultText {
                    anchors.fill: parent
                    color: themeManager.backgroundColor
                    text: instanceDelegate.partition ? instanceDelegate.partition.name : qsTr("ERROR")
                    font.pointSize: 9
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    padding: 5
                    elide: Text.ElideMiddle
                }
            }

            Rectangle {
                id: body
                width: parent.width
                anchors.top: header.bottom
                anchors.bottom: parent.bottom
                color: nodeDelegate.color
                border.color: nodeDelegate.accentColor
                border.width: 1
                radius: 2
                opacity: 0.2

                Rectangle {
                    x: parent.width - Math.min(parent.width * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height * 0.7
                    width: 1
                    color: themeManager.backgroundColor
                }
            }

            PartitionPreview {
                id: preview
                anchors.fill: body
                anchors.margins: 2
                offset: 0
                range: instanceDelegate.instanceRange
                target: instanceDelegate.partition
            }
        }
    }
}
