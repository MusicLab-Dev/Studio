import QtQuick 2.0
import QtQuick.Layouts 1.3

import "../Default"

Rectangle {
    property alias mouseArea: dragHandler
    property alias text: text

    property int filter: 0

    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width * 0.7
    height: width * 1.5
    radius: 15

    DefaultText {
        id: text
        anchors.fill: parent
        text: ""
    }

    MouseArea {
        id: dragHandler
        anchors.fill: parent
        hoverEnabled: true

        onPressed: {
            open(filter)
        }
    }

}
