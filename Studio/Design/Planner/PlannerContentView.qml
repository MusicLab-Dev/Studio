import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

import NodeListModel 1.0

ContentView {
    readonly property real linkThickness: 4
    readonly property real linkHalfThickness: linkThickness / 2
    readonly property real headerMargin: 10
    readonly property real headerHalfMargin: headerMargin / 2
    readonly property real linkOffset: 0.1 * rowHeaderWidth
    readonly property real linkChildOffset: 0.3 * rowHeaderWidth
    readonly property real childOffset: 0.2 * rowHeaderWidth
    readonly property real automationOffset: 0.4 * rowHeaderWidth
    readonly property real linkChildWidth: childOffset - linkOffset
    readonly property real selectedRowHeight: rowHeight * 1.25
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
        y: contentView.yOffset
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