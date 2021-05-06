import QtQuick 2.0

import "../Default"

import AudioAPI 1.0

DefaultSectionWrapper {
    property int currentPlaybackBeat: 0

    label: qsTr("Beat timer")

    DefaultText {
        font.pixelSize: parent.height * 0.75
        anchors.fill: parent
        color: "white"
        text: {
            var left = (currentPlaybackBeat / AudioAPI.beatPrecision).toFixed()
            var right = (100 * (currentPlaybackBeat % AudioAPI.beatPrecision) / 128).toFixed()
            return left + "." + right
        }
    }
}
