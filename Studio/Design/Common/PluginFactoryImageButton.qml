import QtQuick 2.15

import "../Default"

DefaultAnimatedImageButton {
    property string name

    source: name ? "qrc:/Assets/Plugins/" + name + ".gif" : undefined
    fillMode: Image.PreserveAspectFit
    scaleFactor: 1
    showBorder: false
    playing: hovered
}