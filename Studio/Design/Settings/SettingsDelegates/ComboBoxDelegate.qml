import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Row {
    height: 40
    spacing: 5

    DefaultText {
        text: name
        width: Math.max(parent.width * 0.25, 150)
        height: parent.height
        color: "white"
        horizontalAlignment: Text.AlignLeft
    }

    DefaultComboBox {
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        model: range
        currentIndex: indexOfValue(roleValue)
        onCurrentIndexChanged: roleValue = range[currentIndex]
        Component.onCompleted: currentIndex = indexOfValue(roleValue)
    }
}

