import QtQuick 2.15
import QtQuick.Controls 2.15
import CursorManager 1.0

CheckBox {
    property bool elideText: false

    id: control
    text: qsTr("CheckBox")
    checked: true
    hoverEnabled: true
    implicitWidth: 80
    implicitHeight: 30

    onHoveredChanged: {
        if (hovered)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    background: Rectangle {
        id: rect
        width: Math.min(control.width, control.height)
        height: width
        x: control.leftPadding
        y: control.height / 2 - height / 2
        radius: 6
        color: control.checked ? themeManager.contentColor : themeManager.disabledColor
        border.width: control.down ? 2 : control.hovered ? 1 : 0
        border.color: themeManager.accentColor
    }

    indicator: DefaultColoredImage {
        anchors.fill: control.background
        anchors.margins: control.background.width * 0.2
        source: "qrc:/Assets/Checked.png"
        visible: control.checked
        color: themeManager.accentColor
    }

    contentItem: Text {
        text: control.text
        elide: elideText ? Text.ElideRight : Text.ElideNone
        font: control.font
        color: "white"
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.background.width * 1.5
        width: control.width - control.background.width
        height: control.height
    }
}
