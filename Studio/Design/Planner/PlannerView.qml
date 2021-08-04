import QtQuick 2.15
import QtQuick.Layouts 1.15

import ActionsManager 1.0

import "../Default"
import "../Common"

ColumnLayout {
    function onNodeDeleted(targetNode) {
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
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

    readonly property string moduleName: qsTr("Planner")
    property int moduleIndex
    readonly property alias player: plannerFooter.player
    property alias nodeList: contentView.nodeList

    id: plannerView
    focus: true
    spacing: 0

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onPlayContext(pressed) { if (!pressed) return; player.playOrPause() }
        function onReplayContext(pressed) { if (!pressed) return; player.replay(); }
        function onStopContext(pressed) { if (!pressed) return; player.stop(); }
    }

    Connections {
        target: eventDispatcher

        function onPlayPlaylist(pressed) { if (!pressed) return; player.playOrPause() }
        function onReplayPlaylist(pressed) { if (!pressed) return; player.replay(); }
        function onStopPlaylist(pressed) { if (!pressed) return; player.stop(); }
    }

    PlannerHeader {
        id: plannerHeader
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height * 0.12
        z: 1
    }

    PlannerContentView {
        id: contentView
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    PlannerFooter {
        id: plannerFooter
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height * 0.12
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

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onUndo(pressed) { if (!pressed) return; actionsManager.undo(); }
        function onRedo(pressed) { if (!pressed) return; actionsManager.redo(); }
   }
}
