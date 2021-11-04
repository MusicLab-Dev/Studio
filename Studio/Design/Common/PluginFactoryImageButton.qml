import QtQuick 2.15

import "../Default"

DefaultAnimatedImageButton {
    property string name

    source: name ? ":/Assets/Plugins/" + name + ".png" : ""
    showBorder: false
    playing: hovered
}
