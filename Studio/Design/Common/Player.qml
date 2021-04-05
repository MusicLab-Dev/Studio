import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

import Scheduler 1.0

RowLayout {
    property int targetPlaybackMode: Scheduler.Production

    spacing: 0

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333

        DefaultImageButton {
            source: "qrc:/Assets/Replay.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            colorDefault: "white"

            onReleased: {
                app.scheduler.replay(targetPlaybackMode)
            }
        }
    }
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333

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
                else
                    app.scheduler.play(targetPlaybackMode)
            }
        }
    }
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333

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
