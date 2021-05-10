import QtQuick 2.15
import QtQuick.Controls 2.15

Menu {
    id: globalMenu
    width: 200

    delegate: DefaultMenuItem {}

    background: Rectangle {
        border.color: "#338DCF"
        border.width: 1
        z: 1
        color: "transparent"
    }
}
