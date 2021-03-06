import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

import Scheduler 1.0
import NodeModel 1.0

Rectangle {
    property alias player: player
    property alias tweaker: tweaker

    width: parent.width
    height: parent.width
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 3

            ModeSelector {
                id: tweaker
                itemsPaths: [
                    "qrc:/Assets/EditMod.png",
                    "qrc:/Assets/VelocityMod.png",
                    "qrc:/Assets/TunningMod.png",
                    "qrc:/Assets/AfterTouchMod.png",
                ]
                itemsNames: [
                    "Standard",
                    "Velocity",
                    "Tunning",
                    "Aftertouch",
                ]
                width: parent.width / 3
                height: parent.height / 2
                anchors.centerIn: parent
                itemUsableTill: 0
                onItemSelectedChanged: {
                    sequencerView.tweakMode = itemSelected
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 3

            RowLayout {
                anchors.fill: parent
                spacing: 20

                TimerView {
                    currentPlaybackBeat: sequencerView.player.currentPlaybackBeat
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width * 0.25
                }

                Player {
                    id: player
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width * 0.25
                    targetPlaybackMode: Scheduler.Partition
                    isPartitionPlayer: true
                    targetNode: sequencerView.node
                    targetPartitionIndex: sequencerView.partitionIndex
                }

                Bpm {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width * 0.25
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 3

            AddButton {
                id: addBtn
                height: parent.height / 2
                width: height
                anchors.centerIn: parent

                onReleased: {
                    sequencerView.player.stop()
                    if (sequencerView.node.partitions.add()) {
                        sequencerView.partitionIndex = sequencerView.node.partitions.count() - 1
                        sequencerView.partition = sequencerView.node.partitions.getPartition(sequencerView.partitionIndex)
                    }
                }
            }
        }
    }
}

