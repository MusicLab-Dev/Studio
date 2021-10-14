import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../../Default"

RowLayout {
    property alias text: text
    property alias comboBox: comboBox

    spacing: 0

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        DefaultText {
            anchors.fill: parent
            id: text
            width: Math.max(parent.width * 0.15, 150)
            height: parent.height
            color: "white"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        DefaultComboBox {
            id: comboBox
            anchors.centerIn: parent
            //currentIndex: indexOfValue(roleValue)
            //onCurrentIndexChanged: roleValue = range[currentIndex]
            //Component.onCompleted: currentIndex = indexOfValue(roleValue)
        }

    }
}

