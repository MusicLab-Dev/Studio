import QtQuick 2.15

import "../Default"

DefaultSectionWrapper {
    label: "bpm"

    TextEdit {
        anchors.centerIn: parent
        text: qsTr("140:000")
        font.pixelSize: parent.height * 0.75
        color: "white"
    }
}
