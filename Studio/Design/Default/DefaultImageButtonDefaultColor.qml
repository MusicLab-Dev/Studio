import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    property alias source: image.source
    property bool showBorder: true
    property real scaleFactor: 0.5

    id: control
    hoverEnabled: true

    background: Rectangle {
        width: control.width
        height: control.height
        color: "transparent"
        border.width: 1
        border.color: "white"
        radius: 40
        visible: showBorder
    }

    indicator: Image {
        id: image
        anchors.centerIn: control
        width: control.width * scaleFactor
        height: control.height * scaleFactor
        source: control.source
    }
}

