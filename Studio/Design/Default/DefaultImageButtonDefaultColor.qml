import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

Button {
    property alias source: image.source
    property bool showBorder: true
    property real scaleFactor: 0.5

    id: control
    hoverEnabled: true

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    background: Rectangle {
        width: control.width
        height: control.height
        color: "transparent"
        border.width: 1
        border.color: "white"
        radius: 6
        visible: showBorder
    }

    indicator: Image {
        id: image
        anchors.centerIn: control
        width: control.width * scaleFactor
        height: control.height * scaleFactor
        source: control.source
    }
}

