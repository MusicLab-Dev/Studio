import QtQuick 2.15
import QtQuick.Controls 2.15

Menu {
    id: globalMenu
    width: 200

    background: Rectangle {
        color: themeManager.backgroundColor
        radius: 2
    }

    delegate: DefaultMenuItem {
    }
}
