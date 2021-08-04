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

                onPressed: player.timelineBeginMove(mouseX / projectPreview.pixelsPerBeatPrecision)
                onPositionChanged: player.timelineMove(mouseX / projectPreview.pixelsPerBeatPrecision)
                onReleased: player.timelineEndMove()
            }

            Rectangle {
                width: 2
                height: parent.height
                color: "white"
                x: projectPreview.pixelsPerBeatPrecision * player.currentPlaybackBeat
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

    DefaultImageButton {
        visible: contentView.lastSelectedNode && partitionsPreview.hide
        anchors.right: parent.right
        anchors.bottom: parent.top
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        width: height
        height: parent.height * 0.5
        showBorder: false
        scaleFactor: 1
        source: "qrc:/Assets/Note.png"

        onReleased: partitionsPreview.hide = false
    }

    PartitionsPreview {
        id: partitionsPreview
        y: -height
    }
}
