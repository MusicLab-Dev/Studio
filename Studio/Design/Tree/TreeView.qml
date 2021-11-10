import QtQuick 2.15
import QtQuick.Layouts 1.15

import ActionsManager 1.0

import "../Common"

Item {
    function onNodeDeleted(targetNode) {
        actionsManager.nodeDeleted(targetNode)
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        actionsManager.nodePartitionDeleted(targetNode, targetPartitionIndex)
        return false
    }

    property string moduleName: app.project.name
    property int moduleIndex
    property alias player: treeHeader.player

    id: treeView
    focus: true

    onVisibleChanged: {
        if (visible)
            treeHeader.projectPreview.requestUpdate()
    }

    Connections {
        target: app.project.master
        enabled: treeView.visible

        function onGraphChanged() {
            treeHeader.projectPreview.requestUpdate()
        }
    }

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onAction(pressed) { if (pressed) contentView.actionEvent() }
        function onPlayPauseContext(pressed) { if (pressed) player.playOrPause() }
        function onReplayStopContext(pressed) { if (pressed) player.replayOrStop() }
        function onReplayContext(pressed) { if (pressed) player.replay() }
        function onStopContext(pressed) { if (pressed) player.stop() }

        function onUndo(pressed) {
            if (pressed) {
                actionsManager.undo()
            }
        }

        function onRedo(pressed) {
            if (pressed) {
                actionsManager.redo()
            }
        }
    }

    Item {
        anchors.fill: parent

        TreeContentView {
            id: contentView
            anchors.top: treeHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }

        TreeHeader {
            id: treeHeader
            height: parent.height * 0.11
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    TreeNodeMenu {
        id: treeNodeMenu
    }

    PartitionMenu {
        id: partitionMenu
    }

    ActionsManager {
        id: actionsManager
    }

    Connections {
        target: app.project

        function onMasterChanged() { actionsManager.clear() }
    }
}
