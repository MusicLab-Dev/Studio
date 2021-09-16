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
        function onPlayContext(pressed) { if (pressed) player.playOrPause() }
        function onReplayContext(pressed) { if (pressed) player.replay() }
        function onStopContext(pressed) { if (pressed) player.stop() }
    }

    TreeContentView {
        id: contentView
        Layout.fillWidth: true
        Layout.fillHeight: true
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
