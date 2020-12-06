import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    hoverEnabled: true

    background: Rectangle {
        width: control.width
        height: control.height
    }

    indicator: DefaultColoredImage {
        width: control.width
        height: control.height
        source: "qrc:/menu_button.png"
        color: control.pressed ? "#1A6DAA" : control.hovered ? "#338DCF" : "#31A8FF"
    }
}

