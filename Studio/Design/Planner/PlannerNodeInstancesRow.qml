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
            range: AudioAPI.beatRange(-contentView.xOffset / contentView.pixelsPerBeatPrecision, (width - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
            sourceModel: nodeInstances.instances
        }

        delegate: Rectangle {
            property var instanceRange: range
            readonly property int targetPartitionIndex: partitionIndex
            property PartitionModel partition: nodeInstances.partitions.getPartition(targetPartitionIndex)

            id: instanceDelegate
            x: contentView.xOffset + instanceRange.from * contentView.pixelsPerBeatPrecision
            width: (instanceRange.to - instanceRange.from) * contentView.pixelsPerBeatPrecision
            height: contentView.rowHeight
            color: nodeDelegate.color
            border.color: nodeDelegate.accentColor
            border.width: 1
            radius: 2

            Rectangle {
                x: parent.width - Math.min(parent.width * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                y: parent.height / 8
                width: 1
                height: contentView.rowHeight * 3 / 4
                color: nodeDelegate.accentColor
            }

            PartitionPreview {
                id: preview
                anchors.fill: parent
                anchors.margins: 2
                offset: 0
                range: instanceDelegate.instanceRange
                target: instanceDelegate.partition
            }

            DefaultText {
                width: parent.width
                height: parent.height * 0.3
                color: nodeDelegate.accentColor
                text: instanceDelegate.partition ? instanceDelegate.partition.name : qsTr("ERROR")
                fontSizeMode: Text.VerticalFit
                font.pointSize: 12
                elide: Text.ElideMiddle
            }
        }
    }
}
