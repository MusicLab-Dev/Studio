import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0

import "../Default"
import "../Common"

Item {
    property alias projectPreview: projectPreview
    property alias player: player

    Rectangle {
        id: treeFooter
        anchors.fill: parent
        color: themeManager.backgroundColor
    }

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    /*DefaultImageButton {
        id: undoButton
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7
        source: "qrc:/Assets/Previous.png"
        foregroundColor: themeManager.contentColor

        onClicked: actionsManager.undo()

        DefaultToolTip {
            text: "Undo"
            visible: parent.hovered
        }
    }

    DefaultImageButton {
        id: redoButton
        anchors.left: undoButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7
        source: "qrc:/Assets/Next.png"
        foregroundColor: themeManager.contentColor

        onClicked: actionsManager.redo()

        DefaultToolTip {
            text: "Redo"
            visible: parent.hovered
        }
    }*/

    SoundMeter {
        id: soundMeter
        enabled: treeView.visible
        targetNode: app.project.master
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height * 0.56
        width: height * 0.4
        backgroundColor: themeManager.contentColor
    }

    Item {
        id: preview
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: soundMeter.right
        anchors.right: playerArea.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        height: parent.height * 0.56

        Rectangle {
            id: previewBackground
            anchors.fill: parent
            color: themeManager.contentColor
            clip: true
            radius: 6
        }

        TreeProjectPreview {
            id: projectPreview
            anchors.fill: parent
            playerBase: player.playerBase
        }
    }

    RowLayout {
        id: playerArea
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: parent.width * 0.3
        height: parent.height * 0.7
        anchors.verticalCenter: parent.verticalCenter

        TimerView {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.3
            currentPlaybackBeat: player.playerBase.currentPlaybackBeat
        }

        Bpm {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.3
        }

        PlayerRef {
            id: player
            Layout.fillWidth: true
            Layout.fillHeight: true
            playerBase: modulesView.productionPlayerBase
        }
    }
}
