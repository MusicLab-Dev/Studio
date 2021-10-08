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
        playFrom = currentPlaybackBeat
        if (timelineMoveWhilePlaying) {
            timelineMoveWhilePlaying = false
            play()
        }
    }

    function timelineBeginLoopMove(from, to) {
        if (isPlayerRunning) {
            timelineMoveWhilePlaying = true
            pause()
        } else
            timelineMoveWhilePlaying = false
        player.hasLoop = true
        player.loopFrom = from
        player.loopTo = to
    }

    function timelineLoopMove(target) {
        player.loopTo = target
    }

    function timelineInvertedLoopMove(target) {
        player.loopFrom = target
    }

    function timelineEndLoopMove() {
        if (player.loopFrom === player.loopTo)
            player.disableLoopRange()
        else if (timelineMoveWhilePlaying) {
            timelineMoveWhilePlaying = false
            play()
        }
    }

    function disableLoopRange() {
        hasLoop = false
        loopFrom = 0
        loopTo = 0
        app.scheduler.disableLoopRange()
    }

    function pause() {
        if (isPartitionPlayer && !targetNode)
            return;
        timer.stopAndRecordPlaybackBeat()
        app.scheduler.pause()
        app.currentPlayer = player
    }

    function play() {
        var range = player.hasLoop ? AudioAPI.beatRange(player.loopFrom, player.loopTo) : AudioAPI.beatRange(0, 0)
        if (player.hasLoop) {
            if (beginPlaybackBeat < range.from || beginPlaybackBeat > range.to)
                beginPlaybackBeat = range.from
        }
        currentPlaybackBeat = beginPlaybackBeat
        if (isPartitionPlayer) {
            if (!targetNode)
                return;
            app.scheduler.playPartition(targetPlaybackMode, targetNode, targetPartitionIndex, beginPlaybackBeat, range)
        } else
            app.scheduler.play(targetPlaybackMode, beginPlaybackBeat, range)
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
        var value = undefined
        if (player.hasLoop)
            value = player.loopFrom
        else
            value = player.playFrom
        beginPlaybackBeat = value
        currentPlaybackBeat = value
        play()
    }

    function stop() {
        if (isPartitionPlayer && !targetNode)
            return;
        app.scheduler.stop()
        app.currentPlayer = player
        timer.stop()
        var value = undefined
        if (player.hasLoop)
            value = player.loopFrom
        else {
            if (currentPlaybackBeat === player.playFrom)
                player.playFrom = 0
            value = player.playFrom
        }
        beginPlaybackBeat = value
        currentPlaybackBeat = value
    }

    signal updateVolumeCache
    signal stopVolumeCache

    // Inputs
    property int targetPlaybackMode: Scheduler.Production
    property bool isPartitionPlayer: false
    property NodeModel targetNode: null
    property int targetPartitionIndex: 0

    // Loop inputs
    property bool hasLoop: false
    property int playFrom: 0
    property int loopFrom: 0
    property int loopTo: 0
    property int loopRange: loopTo - loopFrom

    // Cache
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
            if (!player.hasLoop)
                currentPlaybackBeat = beginPlaybackBeat + elapsed
            else
                currentPlaybackBeat = player.loopFrom + ((beginPlaybackBeat - player.loopFrom + elapsed) % player.loopRange)
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
            width: height
            anchors.centerIn: parent

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
