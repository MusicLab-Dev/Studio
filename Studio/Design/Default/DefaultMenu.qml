import QtQuick 2.15
import QtQuick.Controls 2.15

Menu {
    id: globalMenu
    width: 200

    delegate: MenuItem {
        id: menuItem
        height: 40
        hoverEnabled: true

        background: Rectangle {
            color: menuItem.hovered ? themeManager.backgroundColor : themeManager.foregroundColor
        }

        contentItem: Text {
            id: contentText
            text: menuItem.text
            font: menuItem.font
            color:  parent.hovered ? "#338DCF": "#295F8B"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    background: Rectangle {
        border.color: "#338DCF"
        border.width: 1
        z: 1
        color: "transparent"
    }
}
