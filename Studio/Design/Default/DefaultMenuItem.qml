import QtQuick 2.15
import QtQuick.Controls 2.15

MenuItem {
    id: menuItem
    height: enabled ? 40 : 0
    visible: enabled
    hoverEnabled: enabled

    background: Rectangle {
        color: menuItem.hovered ? themeManager.accentColor : themeManager.panelColor
        radius: 2
        width: menuItem.width
        height: menuItem.height
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
