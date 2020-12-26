import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Row {
    height: 20
    spacing: 4

    Image {
        id: image
        width: 20
        height: 20
        source: "qrc:/Assets/TestImage4.png"
    }

    DefaultTextButton {
        width: image.x + image.width > workspaceForeground.width - image.x ? workspaceForeground.width - image.x * 0.6 : parent.width * 0.6
        text: fileName
        height: parent.height
    }
}
