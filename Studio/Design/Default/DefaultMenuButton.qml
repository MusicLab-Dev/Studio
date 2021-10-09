import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

DefaultImageButton {
    id: control
    source: "qrc:/Assets/Logo.png"
    colorOnPressed: setColorAlpha("white", 0.5)
    colorHovered: setColorAlpha("white", 0.25)
    colorDefault: "transparent"
    colorDisabled: setColorAlpha(themeManager.disabledColor, 0.5)
    scaleFactor: 1
}

