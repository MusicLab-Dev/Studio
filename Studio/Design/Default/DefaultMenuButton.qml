import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

Button {
    property real imageFactor: 1
    property alias rect: bgRect

    id: control
    hoverEnabled: true

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    background: Rectangle {
        id: bgRect
        width: control.width
        height: control.height
        color: "transparent"
    }

    indicator: DefaultColoredImage {
        id: indicatorImage
        width: control.width * imageFactor
        height: control.height * imageFactor
        anchors.centerIn: control
        source: "qrc:/Assets/MenuButton.png"
        color: control.pressed ? "#1A6DAA" : control.hovered ? themeManager.semiAccentColor : themeManager.accentColor
    }
}

