import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Default"
import "../Common"
import "../Help"

Rectangle {
    property alias projectPreview: projectPreview
    property alias player: player

    id: treeFooter
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
            radius: 6
            samples: 17
            color: "#80000000"
            source: previewBackground
        }

        TreeProjectPreview {
            id: projectPreview
            anchors.fill: parent
            playerBase: player.playerBase
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
