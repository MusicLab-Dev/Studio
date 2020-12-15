import QtQuick 2.15
import QtQuick.Window 2.15

import "../ModulesView"

Window {
    visible: true
    width: 1280
    height: 720
    title: qsTr("MusicLab")

    ModulesView {
        anchors.fill: parent
    }
}
