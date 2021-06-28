import QtQuick 2.15
import QtQuick.Controls 2.15

MenuItem {
    id: menuItem
    height: menuItem.enabled ? 40 : 0
    hoverEnabled: true

    background: Rectangle {
        color: menuItem.hovered ? themeManager.backgroundColor : themeManager.foregroundColor
    }

    contentItem: Text {
        id: contentText
        text: menuItem.text
        font: menuItem.font
        color:  parent.hovered ? themeManager.semiAccentColor : "#295F8B"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}