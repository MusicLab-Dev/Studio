import QtQuick 2.0

import "../Default"

import AudioAPI 1.0

DefaultSectionWrapper {
    property int currentPlaybackBeat: 0

    label: qsTr("Timer")

    DefaultText {
        font.pixelSize: parent.height * 0.75
        anchors.fill: parent
        color: "white"
        text: {
            var left = Math.floor(currentPlaybackBeat / AudioAPI.beatPrecision)
            var right = Math.floor(100 * (currentPlaybackBeat % AudioAPI.beatPrecision) / 128)
            if (right < 10)
                right = "0" + right
            return left + "." + right
        }
    }
}
