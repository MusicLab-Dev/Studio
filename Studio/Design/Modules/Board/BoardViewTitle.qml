import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Column {
    DefaultText {
        id: boardViewTitle
        width: parent.width
        text: qsTr("Board")
        color: "lightgrey"
        font.pointSize: 34
    }

    DefaultText {
        id: boardViewSubtitle
        width: parent.width
        text: qsTr("Make the experience more physical")
        color: "lightgrey"
        font.pointSize: 15
    }
}