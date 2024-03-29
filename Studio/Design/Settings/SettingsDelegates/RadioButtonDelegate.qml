import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../../Default"

Row {
    height: 40
    spacing: 5

    DefaultText {
        id: nameLabel
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: parent.height
        color: "white"
        horizontalAlignment: Text.AlignLeft
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

