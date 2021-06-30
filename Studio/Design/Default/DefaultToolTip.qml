import QtQuick 2.15
import QtQuick.Controls 2.15

ToolTip {
    property alias accentColor: label.color

    id: control

    contentItem: Text {
        id: label
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