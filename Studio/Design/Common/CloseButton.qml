import QtQuick 2.15

import "../Default"

DefaultImageButton {
    source: "qrc:/Assets/Close.png"
    showBorder: false
    scaleFactor: 1
    colorDefault: "red"
    colorOnPressed: "grey"
    colorHovered: themeManager.accentColor
}
