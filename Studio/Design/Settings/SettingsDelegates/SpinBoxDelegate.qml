import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Row {
    height: 40
    spacing: 5

    DefaultText {
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "#295F8B"
    }

    DefaultSpinBox {
        width: 150
        height: parent.height / 1.5
        from: range[0]
        to: range[1]
        stepSize: range[2]
        editable: range[3]
        value: roleValue
        onValueChanged: roleValue = value
    }
}

