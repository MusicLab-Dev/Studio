import QtQuick 2.15
import QtQuick.Controls 2.15

import '.'

Button {
    id: control
    hoverEnabled: true

    background: Rectangle {
        width: control.width
        height: control.height
        color: "transparent"
    }

    indicator: DefaultColoredImage {
        width: control.width
        height: control.height
        source: "qrc:/Assets/EditWorkspaceName.png"
        color: control.pressed ? "#1A6DAA" : control.hovered ? "#338DCF" : "#0D2D47"
    }
}

