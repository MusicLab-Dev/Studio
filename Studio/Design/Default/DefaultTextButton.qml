import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

Button {
    id: control
    hoverEnabled: true

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.pressed ? themeManager.accentColor : control.hovered ? themeManager.accentColor : control.enabled ? "#FFFFFF" : "#FFFFFF"
        // the component is invisible because it is design to be on dark background and its color is based on white
        opacity: control.pressed ? 1.0 : control.hovered ? 0.51 : control.enabled ? 0.71 : 0.44
        elide: Text.ElideRight
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignLeft
     }

    background: Item {}
}
