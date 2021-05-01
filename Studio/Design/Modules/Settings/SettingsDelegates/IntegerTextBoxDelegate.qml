import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../../Default"

Row {
    Text {
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "#295F8B"
    }

    DefaultIntegerTextBox {
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height / 1.5
        bottomRange: range[0]
        topRange: range[1]
        text: roleValue
        onTextChanged: roleValue = text
    }
}

