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
                id: nodeName
                x: nodeView.dataHeaderSpacing
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameWidth
                height: nodeView.dataHeaderNameHeight
                horizontalAlignment: Text.AlignLeft
                text: partitionDelegate.partition ? partitionDelegate.partition.name : ""
                color: "white"
                elide: Text.ElideRight
                font.pointSize: nodeView.dataHeaderNamePointSize
            }

            MuteButton {
                id: muteMenuButton
                x: nodeView.dataHeaderMuteButtonX
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameHeight
                height: nodeView.dataHeaderNameHeight
                muted: partitionDelegate.partition ? partitionDelegate.partition.muted : false

                property int tmp: 0
                onMutedChanged: {
                    if (partitionDelegate.partition)
                        partitionDelegate.partition.muted = muted
                    partitionDelegate.partition.instances.add(AudioAPI.beatRange(tmp * 128, ++tmp * 128))
                }
            }

            SettingsButton {
                id: settingsMenuButton
                x: nodeView.dataHeaderSettingsButtonX
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameHeight
                height: nodeView.dataHeaderNameHeight

                onReleased: {
                    partitionSettingsMenu.openMenu(settingsMenuButton, nodeDelegate.node, partitionDelegate.partition, index)
                }
            }
        }

        MouseArea {
            property int notePlacementBeatPrecision: -1

            id: placementArea
            x: nodeView.dataHeaderWidth
            width: nodeView.dataContentWidth
            height: contentView.rowHeight

            onPressed: {
                notePlacementBeatPrecision =
            }

            onReleased: {
                console.log("Released")
            }

            onPositionChanged: {
                console.log("PositionChanged")
            }

            Repeater {
                model: partitionDelegate.partition.instances

                delegate: Rectangle {
                    x: contentView.surfaceContentGrid.xOffset + contentView.surfaceContentGrid.pixelsPerBeatPrecision * from
                    width: contentView.surfaceContentGrid.pixelsPerBeatPrecision * (to - from)
                    height: contentView.rowHeight
                    color: nodeDelegate.node.color
                    border.color: Qt.lighter(nodeDelegate.node.color)
                }
            }

            Rectangle {
                x: contentView.surfaceContentGrid.xOffset + contentView.surfaceContentGrid.pixelsPerBeatPrecision * placementArea.notePlacementBeatPrecision
                width: contentView.surfaceContentGrid.pixelsPerBeat
                height: contentView.rowHeight
                visible: placementArea.notePlacementBeatPrecision !== -1
                color: Qt.lighter(nodeDelegate.node.color)
            }
        }
    }
}