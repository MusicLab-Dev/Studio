import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import ProjectPreview 1.0
import Scheduler 1.0

import "../Default"
import "../Common"
import "../Help"

Rectangle {
    property alias projectPreview: projectPreview
    property alias player: player

    color: themeManager.backgroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    Item {
        id: preview
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: playerArea.left
        anchors.margins: 10

        HelpArea {
            name: qsTr("Project Preview")
            description: qsTr("Description")
            position: HelpHandler.Position.Left | HelpHandler.Position.Top
            externalDisplay: true
            spacing: 20
        }

        Rectangle {
            id: previewBackground
            anchors.fill: parent
            color: themeManager.foregroundColor
            clip: true
        }

        DropShadow {
            id: shadow
            anchors.fill: previewBackground
            horizontalOffset: 4
            verticalOffset: 4
            radius: 8
            samples: 17
            color: "#80000000"
            source: previewBackground
        }

        ProjectPreview {
            id: projectPreview
            anchors.fill: parent
            target: app.project.master

            MouseArea {
                anchors.fill: parent

                enabled: app.project.master.latestInstance !== 0
                onPressed: player.timelineBeginMove(Math.min(Math.max(mouseX, 0), width) / projectPreview.pixelsPerBeatPrecision)
                onPositionChanged: player.timelineMove(Math.min(Math.max(mouseX, 0), width) / projectPreview.pixelsPerBeatPrecision)
                onReleased: player.timelineEndMove()
            }

            Rectangle {
                width: 1
                height: parent.height
                color: "white"
                x: Math.max(Math.min(projectPreview.pixelsPerBeatPrecision * player.currentPlaybackBeat, previewBackground.width), 0)
                visible: app.project.master.latestInstance !== 0
            }
        }
    }

    Item {
        id: playerArea
        anchors.right: parent.right
        width: parent.width * 0.32
        height: parent.height

        TimerView {
            width: parent.width / 4
            height: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            currentPlaybackBeat: player.currentPlaybackBeat
        }

        Player {
            id: player
            width: parent.width / 2 - 40
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            targetPlaybackMode: Scheduler.Production
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
}
