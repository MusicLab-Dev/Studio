import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../../../Default"

Row {
    anchors.fill: parent

    Text {
        id: nameLabel
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "#295F8B"
    }

    RowLayout {
        width: parent.width - nameLabel.width
        height: parent.height / 1.5
        
        Repeater {
            model: range

            delegate: DefaultRadioButton {
                width: 10
                height: 10
                text: modelData
                down: roleValue === modelData
            }
        }
    }
}

