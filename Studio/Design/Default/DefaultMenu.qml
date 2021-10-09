import QtQuick 2.15
import QtQuick.Controls 2.15

Menu {
    id: globalMenu
    width: 200

    background: Rectangle {
        border.color: themeManager.accentColor
        border.width: 1
        color: themeManager.foregroundColor
        radius: 8
    }

    delegate: DefaultMenuItem {
    }
}
