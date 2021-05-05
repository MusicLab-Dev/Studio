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
    property int currentPlaybackBeat: 0
    property int beginPlaybackBeat: 0
    property alias isPlayerRunning: timer.running
    property bool isSchedulerRunning: app.scheduler.playbackMode === targetPlaybackMode && app.scheduler.running
    property bool timelineMoveWhilePlaying: false

    function timelineBeginMove(target) {
        if (isPlayerRunning) {
            timelineMoveWhilePlaying = true
            app.scheduler.pause(targetPlaybackMode)
            timer.stop()
        } else
            timelineMoveWhilePlaying = false
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

    function pause() {
        app.scheduler.pause(targetPlaybackMode)
        timer.stopAndRecordPlaybackBeat()
        app.currentPlayer = player
    }

    function play() {
        if (contentView.hasLoop)
            app.scheduler.setLoopRange(AudioAPI.beatRange(contentView.loopFrom, contentView.loopTo))
        else
            app.scheduler.disableLoopRange()
        if (isPartitionPlayer)
            app.scheduler.playPartition(targetPlaybackMode, targetNode, targetPartitionIndex, currentPlaybackBeat)
        else
            app.scheduler.play(targetPlaybackMode, currentPlaybackBeat)
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
        if (contentView.hasLoop)
            app.scheduler.setLoopRange(AudioAPI.beatRange(contentView.loopFrom, contentView.loopTo))
        else
            app.scheduler.disableLoopRange()
        if (isPartitionPlayer)
            app.scheduler.playPartition(targetPlaybackMode, targetNode, targetPartitionIndex, contentView.loopFrom)
        else
            app.scheduler.play(targetPlaybackMode, contentView.loopFrom)
        app.currentPlayer = player
        beginPlaybackBeat = contentView.loopFrom
        timer.start()
    }

    function stop() {
        app.scheduler.stop(targetPlaybackMode)
        app.currentPlayer = player
        timer.stop()
        beginPlaybackBeat = 0
        currentPlaybackBeat = 0
    }

    // function prepareForBPMChange() {
    //     if (isSchedulerRunning)
    //         pause()
    // }

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
            var elapsed = app.scheduler.getAudioElapsedBeat()
            if (!contentView.hasLoop)
                currentPlaybackBeat = beginPlaybackBeat + elapsed
            else
                currentPlaybackBeat = beginPlaybackBeat + (elapsed % contentView.loopRange)
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
