import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

ContentView {
    id: contentView
    xOffsetMin: app.project.master ? Math.max(app.project.master.latestInstance, placementBeatPrecisionTo) * -pixelsPerBeatPrecision : 0
    yOffsetMin: nodeView.totalHeight > surfaceContentGrid.height ? surfaceContentGrid.height - nodeView.totalHeight : 0
    timelineBeatPrecision: playlistView.player.currentPlaybackBeat
    audioProcessBeatPrecision: app.scheduler.productionCurrentBeat
    yZoom: 0.25

    PlaylistNodeView {
        id: nodeView
        y: contentView.yOffset
        width: parent.width
    }

    PlaylistPluginSettingsMenu {
        id: pluginSettingsMenu
    }

    PlaylistPartitionSettingsMenu {
        id: partitionSettingsMenu
    }

    PlaylistControlSettingsMenu {
        id: controlSettingsMenu
    }

    PlaylistAutomationSettingsMenu {
        id: automationSettingsMenu
    }
}
