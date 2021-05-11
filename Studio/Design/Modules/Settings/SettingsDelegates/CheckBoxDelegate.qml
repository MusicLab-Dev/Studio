import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../../Default"

Row {
    height: 40
    spacing: 5

    DefaultText {
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "#295F8B"
    }

    DefaultCheckBox {
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height / 1.5
        checked: value
        onCheckedChanged: roleValue = checked
    }
}
