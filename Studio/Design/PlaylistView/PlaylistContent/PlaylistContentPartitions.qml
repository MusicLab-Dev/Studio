import QtQuick 2.15
import QtQuick.Controls 2.15

import PartitionModel 1.0
import AudioAPI 1.0

import "../../Default"
import "../../Common"

Repeater {
    delegate: Item {
        property PartitionModel partition: partitionInstance.instance

        id: partitionDelegate
        width: nodeView.dataHeaderAndContentWidth
        height: contentView.rowHeight

        Rectangle {
            id: dataBackground
            x: nodeView.dataHeaderLeftPadding
            y: nodeView.dataHeaderTopPadding
            width: nodeView.dataHeaderDisplayWidth
            height: parent.height - nodeView.dataHeaderVerticalPadding
            radius: nodeView.dataHeaderRadius
            color: "transparent"
            border.color: nodeDelegate.node ? nodeDelegate.node.color : "white"
            border.width: nodeView.dataHeaderBorderWidth

            DefaultText {
                id: partitionName
                x: nodeView.dataHeaderSpacing
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameWidth
                height: nodeView.dataHeaderNameHeight
                horizontalAlignment: Text.AlignLeft
                text: partitionDelegate.partition ? partitionDelegate.partition.name : ""
                color: "white"
                elide: Text.ElideRight
                fontSizeMode: Text.HorizontalFit
                font.pixelSize: nodeView.dataHeaderNamePixelSize
            }

            MuteButton {
                x: nodeView.dataHeaderMuteButtonX
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameHeight
                height: nodeView.dataHeaderNameHeight
                muted: partitionDelegate.partition ? partitionDelegate.partition.muted : false

                onMutedChanged: {
                    if (partitionDelegate.partition)
                        partitionDelegate.partition.muted = muted
                }
            }

            SettingsButton {
                id: partitionSettingsMenuButton
                x: nodeView.dataHeaderSettingsButtonX
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameHeight
                height: nodeView.dataHeaderNameHeight

                onReleased: {
                    partitionSettingsMenu.openMenu(partitionSettingsMenuButton, nodeDelegate.node, partitionDelegate.partition, index)
                }
            }
        }

        InstancesPlacementArea {
            id: placementArea
            x: nodeView.dataHeaderWidth
            width: nodeView.dataContentWidth
            height: contentView.rowHeight
            instances: partitionDelegate.partition ? partitionDelegate.partition.instances : null
            brushStep: contentView.placementBeatPrecisionBrushStep

            Repeater {
                model: placementArea.instances

                delegate: Rectangle {
                    x: contentView.xOffset + contentView.pixelsPerBeatPrecision * from
                    width: contentView.pixelsPerBeatPrecision * (to - from)
                    height: contentView.rowHeight
                    color: nodeDelegate.node.color
                    border.color: Qt.darker(nodeDelegate.node.color, 1.25)
                    border.width: 2

                    Rectangle {
                        x: Math.min(parent.width * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                        y: parent.height / 8
                        width: 1
                        height: contentView.rowHeight * 3 / 4
                        color: "white"
                    }

                    Rectangle {
                        x: parent.width - Math.min(parent.width * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                        y: parent.height / 8
                        width: 1
                        height: contentView.rowHeight * 3 / 4
                        color: "white"
                    }
                }
            }
        }
    }
}