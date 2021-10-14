import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

import "../Default"

DefaultTextButton {
    property bool filled: false

    id: control
    showBorder: true
    width: 80
    height: 35
    rectItem.color: !control.filled ? "transparent" : control.pressed ? themeManager.accentColor : control.hovered ? themeManager.semiAccentColor : themeManager.accentColor
//    rectItem.radius: 6
//    rectItem.border.color: control.hovered ? themeManager.semiAccentColor : themeManager.accentColor
    rectItem.border.width: control.filled ? control.hovered : 1
    textItem.color: control.filled ? "white" : control.pressed ? themeManager.accentColor : control.hovered ? themeManager.semiAccentColor : "white"
}
