import QtQuick 2.15
import QtQuick.Layouts 1.15

import ActionsManager 1.0

import "../Default"
import "../Common"
import "../Help"

Item {
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

    readonly property string moduleName: contentView.nodeViewRepeater.count ? nodeList.getListName() : qsTr("Planner")
    property int moduleIndex
    readonly property alias player: plannerFooter.player
    property alias nodeList: contentView.nodeList

    id: plannerView
    focus: true

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onPlayContext(pressed) { if (pressed) player.playOrPause() }
        function onReplayContext(pressed) { if (pressed) player.replay() }
        function onStopContext(pressed) { if (pressed) player.stop() }
    }

    Connections {
        target: eventDispatcher

        function onPlayProject(pressed) { if (pressed) player.playOrPause() }
        function onReplayProject(pressed) { if (pressed) player.replay() }
        function onStopProject(pressed) { if (pressed) player.stop() }
    }

    ColumnLayout {
        anchors.fill: parent

        PlannerHeader {
            id: plannerHeader
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.12
            z: 1

            DefaultTextButton {
                text: "?"
                onReleased: helpHandler.open()
                width: 50
                height: 50
            }
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
    }

    HelpHandler {
        id: helpHandler
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
}
