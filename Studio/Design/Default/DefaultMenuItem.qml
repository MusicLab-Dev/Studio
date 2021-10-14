import QtQuick 2.15
import QtQuick.Controls 2.15

MenuItem {
    id: menuItem
    height: enabled ? 40 : 0
    visible: enabled
    hoverEnabled: enabled

    background: Rectangle {
        color: menuItem.hovered ? themeManager.backgroundColor : themeManager.foregroundColor
        radius: 6
        x: 2
        y: 2
        width: menuItem.width - 4
        height: menuItem.height - 4
    }

    contentItem: Text {
        id: contentText
        text: menuItem.text
        font: menuItem.font
        color: "white"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}