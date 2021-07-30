import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

TextField {
    readonly property bool cancelKeyboardEventsOnFocus: true

    id: control
    leftPadding: 0
    placeholderTextColor: "lightgrey"
    hoverEnabled: true

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    onAccepted: focus = false

    background: Rectangle {
        width: parent.width
        height: 2
        y: control.height
        color: control.focus ? themeManager.accentColor : "#001E36"
    }
}
