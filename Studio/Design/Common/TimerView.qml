import QtQuick 2.0

import "../Default"

import AudioAPI 1.0
import CursorManager 1.0

DefaultSectionWrapper {
    property int currentPlaybackBeat: 0
    property bool realTime: false

    label: qsTr("Timer")

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: realTime = !realTime

        onHoveredChanged: {
            if (containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }
    }

    DefaultText {
        font.pixelSize: parent.height * 0.75
        anchors.fill: parent
        color: "white"
        text: {
            var left = Math.floor(currentPlaybackBeat / AudioAPI.beatPrecision)
            var right = Math.floor(100 * (currentPlaybackBeat % AudioAPI.beatPrecision) / 128)
            if (right < 10)
                right = "0" + right
            if (realTime)
                return ((currentPlaybackBeat / AudioAPI.beatPrecision) / (app.scheduler.bpm / 60)).toFixed(2) + " s"
            else
                return left + "." + right
        }
    }
}
