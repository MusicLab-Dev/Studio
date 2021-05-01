import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Common"

ContentView {
    id: contentView
    xOffsetMin: app.project.master ? app.project.master.latestInstance * -pixelsPerBeatPrecision : 0
    yOffsetMin: nodeView.totalHeight > surfaceContentGrid.height ? surfaceContentGrid.height - nodeView.totalHeight : 0
    timelineBeatPrecision: playlistView.player.currentPlaybackBeat
    audioProcessBeatPrecision: app.scheduler.productionCurrentBeat

    PlaylistContentNodeView {
        id: nodeView
        y: contentView.yOffset
        width: parent.width
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
