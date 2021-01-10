import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../../Default"

                                Rectangle {
                                    anchors.fill: parent
        color: "red"
    
Row {
    anchors.fill: parent
    Text {
        text: name
        width: Math.max(parent.width * 0.2, 200)
        color: "white"
    }

    DefaultComboBox {
        width: Math.max(parent.width * 0.1, 100)
        height: parent.height
        model: range
        currentIndex: indexOfValue(value)
    }
}
}