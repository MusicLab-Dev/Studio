import QtQuick 2.15
import QtQuick.Layouts 1.15

import ActionsManager 1.0

import "../Common"
import "../Help"

Item {
    function onNodeDeleted(targetNode) {
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        return false
    }

    property string moduleName: app.project.name
    property int moduleIndex
    property alias player: treeFooter.player

    id: treeView
    focus: true

    onVisibleChanged: {
        if (visible)
            treeFooter.projectPreview.requestUpdate()
    }

    Connections {
        target: app.project.master
        enabled: treeView.visible

        function onGraphChanged() {
            treeFooter.projectPreview.requestUpdate()
        }
    }

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onAction(pressed) { if (pressed) contentView.actionEvent() }
        function onPlayContext(pressed) { if (pressed) player.replayOrPause() }
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

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TreeContentView {
            id: contentView
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        TreeFooter {
            id: treeFooter
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.12
        }
    }

    HelpHandler {
        id: helpHandler
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
}
