import QtQuick 2.0
import QtQuick.Layouts 1.3

import "../Default"

Rectangle {
    property alias mouseArea: mouseArea
    property alias text: text

    anchors.centerIn: parent
    width: parent.width * 0.7
    height: parent.height * 0.7

    DefaultText {
        id: text

        anchors.fill: parent
        text: "Mixer"
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onPressed: {
            close()
        }
    }

}
