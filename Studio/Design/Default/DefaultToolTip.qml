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
        color: themeManager.backgroundColor
        border.color: themeManager.contentColor
        border.width: 1
        radius: 6
    }
}
