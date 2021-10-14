import QtQuick 2.15
import QtQuick.Controls 2.15

ScrollBar {
    property alias color: itemContent.color

    id: control
    active: true
    hoverEnabled: true
    implicitWidth: 12.5

    contentItem: Rectangle {
        id: itemContent
        width: control.width
        height: control.height
        radius: 6
        color: control.pressed || control.hovered ? "#000000" : "#111111"
    }

    background: Rectangle {
        width: control.width
        height: control.height
        radius: 6
        color: "#111111"
    }
}
