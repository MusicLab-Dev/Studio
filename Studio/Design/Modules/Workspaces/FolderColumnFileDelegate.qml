import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Row {
    height: 20
    spacing: 4

    Image {
        width: 20
        height: 20
        source: "qrc:/Assets/TestImage4.png"
    }

    DefaultTextButton {
        text: fileName
        height: parent.height
    }
}