import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import ProjectPreview 1.0
import Scheduler 1.0

import "../Default"
import "../Common"

Item {

    property alias projectPreview: projectPreview
    property alias player: player

    Rectangle {
        anchors.fill: parent
        color: themeManager.foregroundColor
        opacity: 0.8
    }

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
        anchors.rightMargin: 30
        anchors.margins: 10

        Rectangle {
            id: previewBackground
            anchors.fill: parent
            color: themeManager.backgroundColor
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
                width: 4
                height: parent.height
                color: "white"
                x: Math.min(projectPreview.pixelsPerBeatPrecision * player.currentPlaybackBeat - 2, previewBackground.width)
                visible: app.project.master.latestInstance !== 0
            }
        }
    }

    RowLayout {
        id: playerArea
        anchors.right: parent.right
        width: parent.width * 0.3
        height: parent.height
        spacing: 10

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
