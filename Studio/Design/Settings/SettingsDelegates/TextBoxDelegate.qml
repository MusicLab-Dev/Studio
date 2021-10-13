import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Row {
    spacing: 5

    Text {
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "white"
        horizontalAlignment: Text.AlignLeft
    }

    DefaultTextBox {
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height / 1.5
        text: roleValue
        onTextChanged: roleValue = text
    }
}

