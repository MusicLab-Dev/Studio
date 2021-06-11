import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    property real imageFactor: 1
    property string sourceImage: "qrc:/Assets/MenuButton.png"

    property alias rect: bgRect

    id: control
    hoverEnabled: true

    background: Rectangle {
        id: bgRect
        width: control.width
        height: control.height
        color: "transparent"
    }

    indicator: DefaultColoredImage {
        id: indicatorImage
        width: control.width * imageFactor
        height: control.height * imageFactor
        anchors.centerIn: control
        source: sourceImage
        color: control.pressed ? "#1A6DAA" : control.hovered ? "#338DCF" : "#31A8FF"
    }
}

