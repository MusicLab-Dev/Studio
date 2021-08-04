import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

DefaultTextInput {
    id: control
    width: parent.width
    height: parent.height
    leftPadding: height * 0.3
    placeholderText: qsTr("Enter some text")
    placeholderTextColor: color
    hoverEnabled: true
    color: control.hovered || control.focus ? themeManager.accentColor : "#295F8B"

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: control.hovered || control.focus ? themeManager.accentColor : "#295F8B"
    }
}
