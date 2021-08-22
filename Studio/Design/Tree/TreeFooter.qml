import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import ProjectPreview 1.0
import Scheduler 1.0

import "../Default"
import "../Common"

Rectangle {
    property alias projectPreview: projectPreview
    property alias player: player

    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: playerArea.left
        anchors.margins: 10
        color: "#474747"
        clip: true

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
                width: 4
                height: parent.height
                color: "white"
                x: projectPreview.pixelsPerBeatPrecision * player.currentPlaybackBeat - 2
                visible: app.project.master.latestInstance !== 0
            }
        }
    }

    RowLayout {
        id: playerArea
        anchors.right: parent.right
        width: parent.width / 3
        height: parent.height
        spacing: 10
        anchors.rightMargin: 10

        TimerView {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: parent.height * 0.5
            Layout.preferredWidth: parent.width * 0.25
            currentPlaybackBeat: player.currentPlaybackBeat
        }

        Player {
            id: player
            Layout.preferredHeight: parent.height * 0.5
            Layout.preferredWidth: parent.width * 0.25
            targetPlaybackMode: Scheduler.Production
        }

        Bpm {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: parent.height * 0.5
            Layout.preferredWidth: parent.width * 0.25
        }
    }
}
