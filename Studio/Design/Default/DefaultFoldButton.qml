import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    property bool activated: false

    id: control
    hoverEnabled: true

    background: Rectangle {
        width: control.width
        height: control.height
    }

    indicator: DefaultColoredImage {
        width: control.width
        height: control.height
        source: "qrc:/fold_button.png"
        color: control.pressed ? "#2577B9" : control.hovered ? "#174D78" : "#163752"
        rotation: control.actived ? -90 : 0
    }
}
