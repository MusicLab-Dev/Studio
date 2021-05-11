import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../../Default"

Row {
    id: control
    height: controlCol.height
    spacing: 5

    DefaultText {
        id: nameLabel
        text: name
        width: Math.max(parent.width * 0.15, 150)
        height: 40
        color: "#295F8B"
    }


    Column {
        id: controlCol
        width: parent.width - nameLabel.width - parent.spacing
        spacing: 5

        Repeater {
            model: roleValue

            delegate: DefaultText {
                width: controlCol.width
                height: 40
                text: modelData[0] + ": " + modelData[1]
                color: "white"
                horizontalAlignment: Text.AlignLeft
            }
        }
    }
}

