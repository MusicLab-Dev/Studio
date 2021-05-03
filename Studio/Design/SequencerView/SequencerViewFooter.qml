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

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            ModSelector {
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
                width: parent.width / 2
                height: parent.height / 1.25
                anchors.centerIn: parent
                onItemSelectedChanged: {
                    sequencerView.tweakMode = itemSelected
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            Player {
                id: player
                anchors.centerIn: parent
                height: parent.height
                width: 200
                targetPlaybackMode: Scheduler.Partition
                isPartitionPlayer: true
                targetNode: sequencerView.node
                targetPartitionIndex: sequencerView.partitionIndex
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            Bpm {
                anchors.centerIn: parent
                height: parent.height / 2
                width: parent.width / 3
            }
        }
    }
}

