import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

import NodeModel 1.0
import NodeListModel 1.0
import PartitionModel 1.0

ContentView {
    function selectPartition(node, partitionIndex) {
        selectedPartitionNode = node
        selectedPartition = node.partitions.getPartition(partitionIndex)
        selectedPartitionIndex = partitionIndex
        placementBeatPrecisionLastWidth = Qt.binding(function() { return selectedPartition.latestNote })
    }

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
    property alias nodeViewRepeater: nodeViewRepeater
    property NodeListModel nodeList: NodeListModel {
        id: nodeList
    }
    property var lastSelectedNode: null

    property NodeModel selectedPartitionNode: null
    property PartitionModel selectedPartition: null
    property int selectedPartitionIndex: 0

    id: contentView
    enableRows: false
    xOffsetMin: app.project.master ? Math.max(app.project.master.latestInstance, placementBeatPrecisionTo) * -pixelsPerBeatPrecision : 0
    yOffsetMin: nodeView.height > surfaceContentGrid.height - plannerFooter.partitionsPreview.height ? surfaceContentGrid.height - plannerFooter.partitionsPreview.height - nodeView.height : 0
    timelineBeatPrecision: plannerView.player.currentPlaybackBeat
    audioProcessBeatPrecision: app.scheduler.productionCurrentBeat
    yZoom: 0.25

    Column {
        id: nodeView
        y: contentView.yOffset
        width: parent.width

        Repeater {
            id: nodeViewRepeater
            model: contentView.nodeList

            onCountChanged: {
                if (count === 1) {
                    var item = itemAt(0)
                    item.isSelected = true
                    contentView.lastSelectedNode = item
                }
            }

            delegate: PlannerNodeDelegate {
                showChildren: contentView.showChildren
            }
        }
    }
}