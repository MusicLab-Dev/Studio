import QtQuick 2.15
import QtQuick.Controls 2.15

ToolTip {
    id: control

    contentItem: Text {
        text: control.text
        font: control.font
        color: "white"
    }

    background: Rectangle {
        color: themeManager.foregroundColor
        border.color: themeManager.backgroundColor
        border.width: 2
    }
}