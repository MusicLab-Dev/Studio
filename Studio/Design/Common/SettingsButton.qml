import QtQuick 2.15

import "../Default"

DefaultImageButton {
    imgPath: "qrc:/Assets/Settings.png"
    showBorder: false
    scaleFactor: 1
    colorDefault: "white"
    colorOnPressed: "grey"
    colorHovered: themeManager.accentColor
}
