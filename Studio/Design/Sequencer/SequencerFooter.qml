import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"
import "../Help"

import Scheduler 1.0
import NodeModel 1.0
import ThemeManager 1.0
import CursorManager 1.0

Rectangle {
    property alias player: player
    property alias tweaker: tweaker

    width: parent.width
    height: parent.height
    color: themeManager.backgroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    Item {
        visible: false
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.1
        height: parent.height * 0.6

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
            anchors.fill: parent
            itemUsableTill: 0
            onItemSelectedChanged: {
                sequencerView.tweakMode = itemSelected
            }
        }
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.32
        height: parent.height

        TimerView {
            width: parent.width / 4
            height: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            currentPlaybackBeat: player.playerBase.currentPlaybackBeat
        }

        Player {
            id: player
            width: parent.width / 2 - 40
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            targetPlaybackMode: Scheduler.Partition
            isPartitionPlayer: true
            targetNode: sequencerView.node
            targetPartitionIndex: sequencerView.partitionIndex
        }

        Bpm {
            width: parent.width / 4
            height: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
        }

        HelpArea {
            name: qsTr("Player Area")
            description: qsTr("Description")
            position: HelpHandler.Position.Left | HelpHandler.Position.Top
            externalDisplay: true
        }
    }

    ClipboardIndicator {
        anchors.bottom: parent.bottom
        anchors.right: soundMeter.right
        anchors.rightMargin: 15
        anchors.top: parent.top
        width: parent.width * 0.1

        HelpArea {
            name: qsTr("Clipboard")
            description: qsTr("Description")
            position: HelpHandler.Position.Bottom
            externalDisplay: true
        }
    }

    SoundMeter {
        id: soundMeter
        anchors.right: parent.right
        anchors.rightMargin: 15
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height * 0.8
        width: height / 3
        targetNode: sequencerView.node
        enabled: sequencerView.visible
        backgroundColor: themeManager.contentColor

        mouseArea.onHoveredChanged: {
            if (mouseArea.containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }

        HelpArea {
            name: qsTr("Sound meter")
            description: qsTr("Description")
            position: HelpHandler.Position.Right
            externalDisplay: true
        }
    }
}

