import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

import NodeListModel 1.0

ContentView {
    property bool showChildren: true
    property NodeListModel nodeList: NodeListModel {
        id: nodeList
    }

    id: contentView
    enableRows: false
    xOffsetMin: app.project.master ? Math.max(app.project.master.latestInstance, placementBeatPrecisionTo) * -pixelsPerBeatPrecision : 0
    yOffsetMin: nodeView.height > surfaceContentGrid.height ? surfaceContentGrid.height - nodeView.height : 0
    timelineBeatPrecision: playlistView.player.currentPlaybackBeat
    audioProcessBeatPrecision: app.scheduler.productionCurrentBeat
    yZoom: 0.25

    Column {
        id: nodeView
        width: parent.width

        Repeater {
            id: nodeViewRepeater
            model: contentView.nodeList

            delegate: PlannerNodeDelegate {
                showChildren: contentView.showChildren
            }
        }
    }
}