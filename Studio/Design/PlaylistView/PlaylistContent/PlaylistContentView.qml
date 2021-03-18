import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Common"

ContentView {
    id: contentView
    xOffsetMin: -5000
    yOffsetMin: nodeView.totalHeight > height ? height - nodeView.totalHeight : 0

    PlaylistContentNodeView {
        id: nodeView
        anchors.fill: parent
    }

    PlaylistContentPluginSettingsMenu {
        id: pluginSettingsMenu
    }
}
