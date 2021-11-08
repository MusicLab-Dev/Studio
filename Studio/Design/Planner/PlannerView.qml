import QtQuick 2.15
import QtQuick.Layouts 1.15

import ActionsManager 1.0

import "../Default"
import "../Common"

Item {
    function onNodeDeleted(targetNode) {
        actionsManager.nodeDeleted(targetNode)
        var count = nodeList.count()
        for (var i = 0; i < count; ++i) {
            var node = nodeList.getNode(i)
            if (node == targetNode || node.isAParent(targetNode)) {
                modulesView.removeModule(moduleIndex)
                return true
            }
        }
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        actionsManager.nodePartitionDeleted(targetNode, targetPartitionIndex)
        return false
    }

    function loadNode() {
        contentView.showChildren = true
        nodeList.loadNode(app.plannerNodeCache)
        app.plannerNodeCache = null
    }

    function loadMultipleNodes() {
        contentView.showChildren = false
        nodeList.loadNodes(app.plannerNodesCache)
        app.plannerNodesCache = []
    }

    readonly property string moduleName: contentView.nodeViewRepeater.count ? nodeList.getListName() : qsTr("Planner")
    property int moduleIndex
    readonly property alias player: plannerFooter.player
    property alias nodeList: contentView.nodeList

    id: plannerView
    focus: true

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onPlayPauseContext(pressed) { if (pressed) player.playOrPause() }
        function onReplayStopContext(pressed) { if (pressed) player.replayOrStop() }
        function onReplayContext(pressed) { if (pressed) player.replay() }
        function onStopContext(pressed) { if (pressed) player.stop() }

        function onUndo(pressed) {
            if (pressed) {
                actionsManager.undo()
                contentView.resetPlacementAreaSelection()
            }
        }

        function onRedo(pressed) {
            if (pressed) {
                actionsManager.redo()
                contentView.resetPlacementAreaSelection()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PlannerHeader {
            id: plannerHeader
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.12
            z: 1
        }

        Rectangle {
            color: "black"
            visible: sequencerControls.visible
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 1
            z: 1
        }

        ControlsAutomationsFlow {
            id: sequencerControls
            node: contentView.selectedNode ? contentView.selectedNode.node : null
            Layout.fillWidth: true
            visible: node
            z: 1
        }

        PlannerContentView {
            id: contentView
            Layout.fillWidth: true
            Layout.fillHeight: true

            Behavior on y {
                NumberAnimation { duration: 200 }
            }
        }

        PlannerFooter {
            id: plannerFooter
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.12
        }
    }

    PlannerNodeMenu {
        id: plannerNodeMenu
    }

    PartitionMenu {
        id: partitionMenu
    }

    ActionsManager {
        id: actionsManager
    }
}
