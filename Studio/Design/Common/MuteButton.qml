import QtQuick 2.0
import "../Default"

Item {
    property bool isMuted: true
    property alias color: speaker.color

    MouseArea {
        anchors.fill: parent
        onClicked: {
            isMuted = !isMuted
        }
    }

    DefaultColoredImage {
        id: speaker
        source: "qrc:/Assets/Mute.png"
        height: parent.height
        width: parent.width
    }

    DefaultColoredImage {
        source: "qrc:/Assets/Disabled.png"
        height: parent.height
        width: parent.width
        visible: isMuted
    }
}
