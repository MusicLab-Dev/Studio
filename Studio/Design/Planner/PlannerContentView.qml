import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"
import "../Help"

import AudioAPI 1.0
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
    readonly property real headerMargin: 3
    readonly property real headerHalfMargin: headerMargin / 2
    readonly property real linkOffset: 0.1 * rowHeaderWidth
    readonly property real linkChildOffset: 0.3 * rowHeaderWidth
    readonly property real childOffset: 0.2 * rowHeaderWidth
    readonly property real automationOffset: 0.4 * rowHeaderWidth
    readonly property real linkChildWidth: childOffset - linkOffset
    readonly property real selectedRowHeight: rowHeight * 1.25
    property bool showChildren: true
    property alias nodeViewRepeater: nodeViewRepeater
    property alias partitionsPreview: partitionsPreview
    property NodeListModel nodeList: NodeListModel {
        id: nodeList
    }
    // Selected node
    property var lastSelectedNode: null

    // Selected partition
    property NodeModel selectedPartitionNode: null
    property PartitionModel selectedPartition: null
    property int selectedPartitionIndex: 0

    // Piano
    property int targetOctave: 5
    readonly property int keysPerOctave: 12

    signal resetPlacementAreaSelection

    id: contentView
    playerBase: plannerView.player.playerBase
    enableRows: false
    xOffsetMin: app.project.master ? Math.max(app.project.master.latestInstance, placementBeatPrecisionTo) * -pixelsPerBeatPrecision : 0
    yOffsetMin: -Math.max(nodeView.height - height / 2, 0)
    yZoom: 0.25
    bottomOverlayMargin: partitionsPreview.requiredVisibility ? partitionsPreview.height : 0

    Component.onCompleted: animDelayTimer.start()

    Timer {
        id: animDelayTimer
        interval: 0

        onTriggered: {
            partitionsBehavior.enabled = true
            if (nodeViewRepeater.count === 1) {
                var item = nodeViewRepeater.itemAt(0)
                item.isSelected = true
                contentView.lastSelectedNode = item
            }
        }
    }

    Connections {
        function launch(pressed, key) {
            if (contentView.lastSelectedNode) {
                contentView.lastSelectedNode.node.partitions.addOnTheFly(
                    AudioAPI.noteEvent(!pressed, (contentView.targetOctave * contentView.keysPerOctave) + key, AudioAPI.velocityMax, 0),
                    contentView.lastSelectedNode.node,
                    0,
                    false
                )
            }
        }

        id: notesConnections
        target: eventDispatcher
        enabled: plannerView.moduleIndex === modulesView.selectedModule && contentView.lastSelectedNode

        function onNote0(pressed) { launch(pressed, 0) }
        function onNote1(pressed) { launch(pressed, 1) }
        function onNote2(pressed) { launch(pressed, 2) }
        function onNote3(pressed) { launch(pressed, 3) }
        function onNote4(pressed) { launch(pressed, 4) }
        function onNote5(pressed) { launch(pressed, 5) }
        function onNote6(pressed) { launch(pressed, 6) }
        function onNote7(pressed) { launch(pressed, 7) }
        function onNote8(pressed) { launch(pressed, 8) }
        function onNote9(pressed) { launch(pressed, 9) }
        function onNote10(pressed) { launch(pressed, 10) }
        function onNote11(pressed) { launch(pressed, 11) }
    }

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

    PartitionsPreview {
        id: partitionsPreview
        y: !partitionsPreview.requiredVisibility ? parent.height : parent.height - height

        Behavior on y {
            id: partitionsBehavior
            enabled: false

            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
                onFinished: partitionsPreview.visible = partitionsPreview.requiredVisibility
            }
        }

        HelpArea {
            name: qsTr("Partitions")
            description: qsTr("Description")
            position: HelpHandler.Position.Top
            externalDisplay: true
            visible: partitionsPreview.requiredVisibility
        }
    }
}
