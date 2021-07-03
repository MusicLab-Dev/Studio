import QtQuick 2.15

import "../Default"

import PartitionInstancesModel 1.0
import PartitionInstancesModelProxy 1.0
import PartitionPreview 1.0
import AudioAPI 1.0

Item {
    clip: true

    Repeater {
        model: PartitionInstancesModelProxy {
            range: AudioAPI.beatRange(-contentView.xOffset / contentView.pixelsPerBeatPrecision, (width - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
            sourceModel: nodeInstances.instances
        }

        delegate: Rectangle {
            property var instanceRange: range

            id: instanceDelegate
            x: contentView.xOffset + instanceRange.from * contentView.pixelsPerBeatPrecision
            width: (instanceRange.to - instanceRange.from) * contentView.pixelsPerBeatPrecision
            height: contentView.rowHeight
            color: nodeDelegate.color
            border.color: nodeDelegate.accentColor
            border.width: 2

            Rectangle {
                x: Math.min(parent.width * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                y: parent.height / 8
                width: 1
                height: contentView.rowHeight * 3 / 4
                color: nodeDelegate.accentColor
            }

            Rectangle {
                x: parent.width - Math.min(parent.width * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                y: parent.height / 8
                width: 1
                height: contentView.rowHeight * 3 / 4
                color: nodeDelegate.accentColor
            }

            PartitionPreview {
                anchors.fill: parent
                anchors.margins: 2
                offset: 0
                range: instanceDelegate.instanceRange
                target: nodeInstances.partitions.getPartition(partitionIndex)
            }
        }
    }
}