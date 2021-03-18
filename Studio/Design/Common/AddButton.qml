import QtQuick 2.15

import "../Default"

DefaultImageButton {
    source: "qrc:/Assets/Plus.png"
    showBorder: false
    scaleFactor: 1
    colorDefault: "white"
    colorOnPressed: "grey"
    colorHovered: themeManager.accentColor
}
