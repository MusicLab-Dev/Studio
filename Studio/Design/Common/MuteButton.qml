import QtQuick 2.15
import "../Default"

DefaultImageButton {
    property bool muted: false

    source: muted ? "qrc:/Assets/Muted.png" : "qrc:/Assets/Unmuted.png"
    colorOnPressed: "grey"
    colorHovered: "lightgrey"
    colorDefault: "white"
    showBorder: false
    scaleFactor: 1

    onReleased: muted = !muted
}
