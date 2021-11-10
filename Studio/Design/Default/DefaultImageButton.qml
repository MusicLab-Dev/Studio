import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

Button {
    property alias image: image
    property alias source: image.source
    property alias fillMode: image.fillMode
    property color colorOnPressed: themeManager.accentColor
    property color colorHovered: themeManager.semiAccentColor
    property color colorDefault: "white"
    property color colorDisabled: themeManager.disabledColor
    property real scaleFactor: 0.5
    property alias showBorder: backgroundRect.visible
    property alias backgroundRadius: backgroundRect.radius
    property alias foregroundColor: backgroundRect.color
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
        color: themeManager.panelColor
        radius: 6
        visible: true
        border.width: 0
        border.color: "black"
    }

    indicator: DefaultColoredImage {
        id: image
        anchors.centerIn: control
        width: control.width * scaleFactor
        height: control.height * scaleFactor
        source: control.source
        color: control.enabled ? control.pressed ? colorOnPressed : control.hovered ? colorHovered : colorDefault : colorDisabled
    }
}

