import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Common"

ContentView {
    id: contentView
    xOffsetMin: -5000
    yOffsetMin: nodeView.totalHeight > height ? height - nodeView.totalHeight : 0
    timelineBeatPrecision: playlistView.player.currentPlaybackBeat
    audioProcessBeatPrecision: app.scheduler.productionCurrentBeat

    PlaylistContentNodeView {
        id: nodeView
        anchors.fill: parent
    }

    PlaylistContentPluginSettingsMenu {
        id: pluginSettingsMenu
    }

    PlaylistContentPartitionSettingsMenu {
        id: partitionSettingsMenu
    }

    PlaylistContentControlSettingsMenu {
        id: controlSettingsMenu
    }

    PlaylistContentAutomationSettingsMenu {
        id: automationSettingsMenu
    }
}
