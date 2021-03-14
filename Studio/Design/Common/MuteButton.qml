import QtQuick 2.15
import "../Default"

DefaultImageButton {
    property bool isMuted: true
    property alias color: speaker.color

    imgPath: isMuted ? "qrc:/Assets/Mute.png" : "qrc:/Assets/Disabled.png"

    onReleased: isMuted = !isMuted
}
