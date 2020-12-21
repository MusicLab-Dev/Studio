import QtQuick 2.15
import QtQuick.Window 2.15

import "../Modules/Plugins"
import "../Modules/Workspaces"

Window {
    visible: true
    width: 1920
    height: 1080
    title: qsTr("MusicLab")

    // PluginsView {
    //     anchors.fill: parent
    // }

    WorkspacesView {
        anchors.fill: parent
    }
}
