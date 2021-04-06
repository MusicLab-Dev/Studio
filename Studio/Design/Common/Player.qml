import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

import Scheduler 1.0
import NodeModel 1.0

RowLayout {
    property int targetPlaybackMode: Scheduler.Production
    property bool isPartitionPlayer: false
    property NodeModel targetNode: null
    property int targetPartitionIndex: 0

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
            colorDefault: "white"

            onReleased: {
                if (isPartitionPlayer)
                    app.scheduler.replayPartition(targetPlaybackMode, targetNode, targetPartitionIndex)
                else
                    app.scheduler.replay(targetPlaybackMode)

            }
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
            property bool playing: app.scheduler.playbackMode === targetPlaybackMode && app.scheduler.running

            source: playing ? "qrc:/Assets/Pause.png" : "qrc:/Assets/Play.png"
            height: parent.height / 1.5
            width: parent.height / 1.5
            anchors.centerIn: parent
            colorDefault: "white"

            onReleased: {
                if (playing)
                    app.scheduler.pause(targetPlaybackMode)
                else {
                    if (isPartitionPlayer)
                        app.scheduler.playPartition(targetPlaybackMode, targetNode, targetPartitionIndex)
                    else
                        app.scheduler.play(targetPlaybackMode)
                }
            }
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

            onReleased: {
                app.scheduler.stop(targetPlaybackMode)
            }
        }
    }
}
