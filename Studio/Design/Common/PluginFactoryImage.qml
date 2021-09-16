import QtQuick 2.15

import "../Default"

DefaultColoredAnimatedImage {
    property string name

    source: name ? "qrc:/Assets/Plugins/" + name + ".gif" : ""
    fillMode: Image.PreserveAspectFit
    color: themeManager.accentColor
}