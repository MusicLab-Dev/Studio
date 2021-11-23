import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

import Scheduler 1.0

Rectangle {
    property alias player: playerArea.player

    width: parent.width
    height: parent.width
    color: themeManager.backgroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    DefaultImageButton {
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
    }

    EditionModeSelector {
        id: editModeSelector
        anchors.left: redoButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height * 0.7
        width: parent.width * 0.12
    }

    PlayerRefArea {
        id: playerArea
        player.playerBase: modulesView.productionPlayerBase
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: parent.width * 0.3
        height: parent.height * 0.7
        anchors.verticalCenter: parent.verticalCenter
    }
}
