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
                    partitionDelegate.partition.instances.add(AudioAPI.beatRange(++tmp, ++tmp))
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

        Row {
            x: nodeView.dataHeaderWidth
            width: nodeView.dataWidth
            height: contentView.rowHeight

            Repeater {
                model: partitionDelegate.partition.instances

                delegate: Rectangle {
                    width: 200
                    height: 100
                    color: "red"

                    Text {
                        text: from + " " + to
                    }
                }
            }
        }
    }
}