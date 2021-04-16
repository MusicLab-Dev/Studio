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

    DefaultCheckBox {
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height / 1.5
        checked: value
        onCheckedChanged: roleValue = checked
    }

    // Rectangle {
    //     visible: desc.text !== ""
    //     width: 1
    //     height parent.height * 0.8
    //     anchors.verticalCenter: parent.verticalCenter
    //     color: "#295F8B"
    // }

    // Text {
    //     id: desc
    //     visible: desc.text !== ""
    //     text: description
    //     height: parent.height
    //     color: "#295F8B"
    // }
}
