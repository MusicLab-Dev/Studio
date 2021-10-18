import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

Button {
    property alias playing: image.playing
    property alias source: image.source
    property color colorOnPressed: "#1A6DAA"
    property color colorHovered: themeManager.semiAccentColor
    property color colorDefault: themeManager.accentColor
    property color colorDisabled: themeManager.disabledColor
    property real scaleFactor: 0.5
    property alias showBorder: backgroundRect.visible
    property alias backgroundRadius: backgroundRect.radius
    property alias backgroundColor: backgroundRect.color
    property alias borderColor: backgroundRect.border.color
    property alias borderWidth: backgroundRect.border.width

    id: control
    hoverEnabled: true

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    background: Rectangle {
        id: backgroundRect
        width: control.width
        height: control.height
        color: "transparent"
        radius: 6
        visible: true
        border.width: 1
        border.color: "white"
    }

    indicator: DefaultColoredAnimatedImage {
        id: image
        anchors.centerIn: control
        width: control.width * scaleFactor
        height: control.height * scaleFactor
        source: control.source
        color: control.enabled ? control.pressed ? colorOnPressed : control.hovered ? colorHovered : colorDefault : colorDisabled
    }
}

