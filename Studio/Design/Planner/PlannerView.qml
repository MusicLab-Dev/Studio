import QtQuick 2.15

import "../Default"

Column {
    readonly property string moduleName: qsTr("Planner")
    property int moduleIndex
    readonly property alias player: plannerFooter.player

    function onNodeDeleted(targetNode) {
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        return false
    }

    function loadNode() {
        nodeList.loadNode(app.plannerNodeCache)
        app.plannerNodeCache = null
    }

    function loadMultipleNodes() {
        nodeList.loadNodes(app.plannerNodesCache)
        app.plannerNodesCache = []
    }

    property alias nodeList: contentView.nodeList

    id: plannerView
    focus: true

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
        width: parent.width
        height: parent.height * 0.15
        z: 1
    }

    PlannerContentView {
        id: contentView
        width: parent.width
        height: parent.height * 0.7
    }

    PlannerFooter {
        id: plannerFooter
        width: parent.width
        height: parent.height * 0.15
    }

    PlannerNodeMenu {
        id: plannerNodeMenu
    }

    PlannerPartitionMenu {
        id: plannerPartitionMenu
    }
}
