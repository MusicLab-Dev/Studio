import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

import Scheduler 1.0
import NodeModel 1.0
import AudioAPI 1.0

RowLayout {
    property int targetPlaybackMode: Scheduler.Production
    property bool isPartitionPlayer: false
    property NodeModel targetNode: null
    property int targetPartitionIndex: 0
    property real currentPlaybackBeat: 0
    property real beginPlaybackBeat: 0
    property real playTimestamp: 0
    property real currentTimestamp: 0
    property alias isPlayerRunning: timer.running
    property bool isSchedulerRunning: app.scheduler.playbackMode === targetPlaybackMode && app.scheduler.running
    property bool timelineMoveWhilePlaying: false

    function timelineBeginMove(target) {
        if (isPlayerRunning) {
            timelineMoveWhilePlaying = true
            app.scheduler.pause(targetPlaybackMode)
            timer.stop()
        }
        currentPlaybackBeat = target
        beginPlaybackBeat = target
    }

    function timelineMove(target) {
        currentPlaybackBeat = target
        beginPlaybackBeat = target
    }

    function timelineEndMove() {
        if (timelineMoveWhilePlaying) {
            timelineMoveWhilePlaying = false
            playOrPause()
        }
    }

    function playOrPause() {
        if (isSchedulerRunning) {
            app.scheduler.pause(targetPlaybackMode)
            timer.stopAndRecordPlaybackBeat()
        } else {
            if (isPartitionPlayer)
                app.scheduler.playPartition(targetPlaybackMode, targetNode, targetPartitionIndex, currentPlaybackBeat)
            else
                app.scheduler.play(targetPlaybackMode, currentPlaybackBeat)
            timer.start()
        }
        playTimestamp = new Date().getTime()
        app.currentPlayer = player
    }

    function replay() {
        if (isPartitionPlayer)
            app.scheduler.replayPartition(targetPlaybackMode, targetNode, targetPartitionIndex)
        else
            app.scheduler.replay(targetPlaybackMode)
        app.currentPlayer = player
        beginPlaybackBeat = 0
        playTimestamp = new Date().getTime()
        timer.start()
    }

    function stop() {
        app.scheduler.stop(targetPlaybackMode)
        app.currentPlayer = player
        timer.stop()
        beginPlaybackBeat = 0
        currentPlaybackBeat = 0
    }

    id: player
    spacing: 0

    Connections {
        target: app

        function onCurrentPlayerChanged() {
            if (app.currentPlayer !== player && timer.running)
                timer.stopAndRecordPlaybackBeat()
        }
    }

    Timer {
        function stopAndRecordPlaybackBeat() {
            timer.stop()
            beginPlaybackBeat = currentPlaybackBeat
        }

        id: timer
        interval: 16
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            currentTimestamp = new Date().getTime()
            var elapsedMs = (currentTimestamp - playTimestamp)
            currentPlaybackBeat = beginPlaybackBeat + elapsedMs * (app.project.bpm / 60000) * AudioAPI.beatPrecision
        }
    }

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.250

        DefaultImageButton {
            source: "qrc:/Assets/Replay.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            colorDefault: "white"

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
            source: player.isSchedulerRunning ? "qrc:/Assets/Pause.png" : "qrc:/Assets/Play.png"
            height: parent.height / 1.5
            width: parent.height / 1.5
            anchors.centerIn: parent
            colorDefault: "white"

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
            colorDefault: "white"

            onReleased: player.stop()
        }
    }
}
