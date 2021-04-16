import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../../Default"

Row {
    anchors.fill: parent

    Text {
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "#295F8B"
    }

    DefaultComboBox {
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height / 1.5
        model: range
        currentIndex: indexOfValue(roleValue)
        onCurrentIndexChanged: roleValue = range[currentIndex]
        Component.onCompleted: currentIndex = indexOfValue(roleValue)
    }
}

