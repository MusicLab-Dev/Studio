import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

RowLayout {
    function timelineBeginMove(target) { return playerBase.timelineBeginMove(target) }
    function timelineMove(target) { return playerBase.timelineMove(target) }
    function timelineEndMove() { return playerBase.timelineEndMove() }
    function timelineBeginLoopMove(from, to) { return playerBase.timelineBeginLoopMove(from, to) }
    function timelineLoopMove(target) { return playerBase.timelineLoopMove(target) }
    function timelineInvertedLoopMove(target) { return playerBase.timelineInvertedLoopMove(target) }
    function timelineEndLoopMove() { return playerBase.timelineEndLoopMove() }
    function disableLoopRange() { return playerBase.disableLoopRange() }
    function pause() { return playerBase.pause() }
    function play() { return playerBase.play() }
    function playOrPause() { return playerBase.playOrPause() }
    function replay() { return playerBase.replay() }
    function replayOrStop() { return playerBase.replayOrStop() }
    function stop() { return playerBase.stop() }

    // Inputs
    property PlayerBase playerBase

    id: player
    spacing: 0

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.250

        DefaultImageButton {
            source: "qrc:/Assets/Replay.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            onReleased: player.replay()
        }
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.125
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.250

        DefaultImageButton {
            source: !playerBase.isPlayerRunning && app.scheduler.running ? "qrc:/Assets/Pause.png" : "qrc:/Assets/Play.png"
            height: parent.height / 1.5
            width: height
            anchors.centerIn: parent
            colorDefault: app.scheduler.running ? themeManager.accentColor : "white"

            onReleased: player.playOrPause()
        }
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.125
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.250

        DefaultImageButton {
            source: "qrc:/Assets/Stop.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left

            onReleased: player.stop()
        }
    }
}
