import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

RadioButton {
    property bool elideText: false

    id: control
    text: qsTr("RadioButton")
    hoverEnabled: true
    down: true

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    background: Rectangle {
        implicitHeight: 25
        implicitWidth: 25
        x: control.leftPadding
        y: control.height / 2 - height / 2
        radius: 6
        color: themeManager.foregroundColor
        border.width: control.down ? 2 : control.hovered ? 1 : 0
        border.color: control.hovered ? themeManager.accentColor : "transparent"
    }

    indicator: Rectangle {
        anchors.fill: control.background
        anchors.margins: control.background.width * 0.15
        color: control.down ? "#001E36" : "transparent"
        radius: 6
    }

    contentItem: Text {
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.background.width * 1.5
        text: control.text
        elide: elideText ? Text.ElideRight : Text.ElideNone
        font: control.font
        color: control.selected || control.hovered ? themeManager.accentColor : "#295F8B"
    }
}
