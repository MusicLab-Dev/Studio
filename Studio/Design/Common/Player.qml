import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

import Scheduler 1.0
import NodeModel 1.0
import AudioAPI 1.0

RowLayout {
    function timelineBeginMove(target) {
        if (isPlayerRunning) {
            timelineMoveWhilePlaying = true
            pause()
        } else
            timelineMoveWhilePlaying = false
        beginPlaybackBeat = target
        currentPlaybackBeat = target
    }

    function timelineMove(target) {
        beginPlaybackBeat = target
        currentPlaybackBeat = target
    }

    function timelineEndMove() {
        if (timelineMoveWhilePlaying) {
            timelineMoveWhilePlaying = false
            play()
        }
    }

    function timelineBeginLoopMove() {
        if (isPlayerRunning) {
            timelineMoveWhilePlaying = true
            pause()
        } else
            timelineMoveWhilePlaying = false
    }

    function timelineEndLoopMove() {
        if (timelineMoveWhilePlaying) {
            timelineMoveWhilePlaying = false
            play()
        }
    }

    function pause() {
        if (isPartitionPlayer && !targetNode)
            return;
        timer.stopAndRecordPlaybackBeat()
        app.scheduler.pause(targetPlaybackMode)
        app.currentPlayer = player
    }

    function play() {
        var loopRange = contentView.hasLoop ? AudioAPI.beatRange(contentView.loopFrom, contentView.loopTo) : AudioAPI.beatRange(0, 0)
        if (contentView.hasLoop) {
            if (beginPlaybackBeat < loopRange.from || beginPlaybackBeat > loopRange.to)
                beginPlaybackBeat = loopRange.from
        }
        currentPlaybackBeat = beginPlaybackBeat
        if (isPartitionPlayer) {
            if (!targetNode)
                return;
            app.scheduler.playPartition(targetPlaybackMode, targetNode, targetPartitionIndex, beginPlaybackBeat, loopRange)
        } else
            app.scheduler.play(targetPlaybackMode, beginPlaybackBeat, loopRange)
        timer.start()
        app.currentPlayer = player
    }

    function playOrPause() {
        if (isSchedulerRunning)
            pause()
        else
            play()
    }

    function replay() {
        beginPlaybackBeat = 0
        currentPlaybackBeat = 0
        play()
    }

    function stop() {
        if (isPartitionPlayer && !targetNode)
            return;
        app.scheduler.stop(targetPlaybackMode)
        app.currentPlayer = player
        timer.stop()
        beginPlaybackBeat = contentView.loopFrom
        currentPlaybackBeat = contentView.loopFrom
    }

    property int targetPlaybackMode: Scheduler.Production
    property bool isPartitionPlayer: false
    property NodeModel targetNode: null
    property int targetPartitionIndex: 0
    property int currentPlaybackBeat: 0
    property int beginPlaybackBeat: 0
    property alias isPlayerRunning: timer.running
    property bool isSchedulerRunning: app.scheduler.playbackMode === targetPlaybackMode && app.scheduler.running
    property bool timelineMoveWhilePlaying: false

    id: player
    spacing: 0

    Component.onDestruction: {
        if (isPlayerRunning)
            stop()
    }

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
        running: false

        onTriggered: {
            var elapsed = app.scheduler.getAudioElapsedBeat()
            if (!contentView.hasLoop)
                currentPlaybackBeat = beginPlaybackBeat + elapsed
            else
                currentPlaybackBeat = contentView.loopFrom + ((beginPlaybackBeat - contentView.loopFrom + elapsed) % contentView.loopRange)
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
