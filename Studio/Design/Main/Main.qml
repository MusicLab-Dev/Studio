import QtQuick 2.15
import QtQuick.Window 2.15

import "../Default"

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("MusicLab")

    DefaultCheckBox {
        anchors.centerIn: parent
    }
}
