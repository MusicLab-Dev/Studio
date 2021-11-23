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
    readonly property alias player: plannerHeader.player
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

    Item {
        anchors.fill: parent

        ControlsAutomationsFlow {
            id: sequencerControls
            anchors.top: plannerHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            node: contentView.selectedNode ? contentView.selectedNode.node : null
            visible: node
            z: 1
            menuFunc: function() { plannerNodeMenu.openMenu(sequencerControls.menuButton, sequencerControls.node) }
            onAutomationSelected: {
                if (contentView.selectedNode.showAutomations && contentView.selectedNode.selectedAutomation === automationIndex)
                    contentView.selectedNode.hideAutomations()
                else
                    contentView.selectedNode.selectAutomation(automationIndex)
            }
        }

        PlannerContentView {
            id: contentView
            anchors.top: selectedNode === null ? plannerHeader.bottom : sequencerControls.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Behavior on y {
                NumberAnimation { duration: 200 }
            }
        }

        PlannerHeader {
            id: plannerHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height * 0.11
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
