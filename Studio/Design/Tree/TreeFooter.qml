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
        anchors.margins: 15

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

            ContentViewTimelineBar {
                id: playToBar
                height: parent.height + 20
                y: -10
                color: themeManager.timelineColor
                x: Math.max(Math.min(projectPreview.pixelsPerBeatPrecision * player.playerBase.currentPlaybackBeat, previewBackground.width), 0)
                visible: app.project.master.latestInstance !== 0
            }

            ContentViewTimelineBarCursor {
                id: playToCursor
                width: 10
                height: 10
                x: playToBar.x - width / 2
                y: -height - 2
                visible: playToBar.visible
            }

            ContentViewTimelineBar {
                id: playFromBar
                height: parent.height + 20
                y: -10
                color: themeManager.accentColor
                opacity: 0.5
                x: Math.max(Math.min(projectPreview.pixelsPerBeatPrecision * player.playerBase.playFrom, previewBackground.width), 0)
                visible: playToBar.visible
            }

            ContentViewTimelineBarCursor {
                id: playFromCursor
                opacity: 0.5
                width: 10
                height: 10
                x: playFromBar.x - width / 2
                y: -height - 2
                color: themeManager.accentColor
                visible: playToBar.visible
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
            currentPlaybackBeat: player.playerBase.currentPlaybackBeat
        }

        PlayerRef {
            id: player
            width: parent.width / 2 - 40
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            playerBase: modulesView.productionPlayerBase
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
