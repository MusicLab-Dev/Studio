import QtQuick 2.15
import QtQuick.Window 2.15

import "../Modules/Plugins"

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("MusicLab")

    PluginsView {
        anchors.fill: parent
    }
}
