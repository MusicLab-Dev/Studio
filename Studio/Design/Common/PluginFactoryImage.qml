import QtQuick 2.15

import "../Default"

DefaultColoredAnimatedImage {
    property string name

    source: name ? ":/Assets/Plugins/" + name + ".png" : ""
    color: themeManager.accentColor
}
