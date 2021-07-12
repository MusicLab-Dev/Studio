import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"

ColumnLayout {
    function onNodeDeleted(targetNode) {
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        return false
    }

    property string moduleName: "Project"
    property int moduleIndex

    id: treeView
    focus: true
    spacing: 0

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onAction(pressed) {
            if (!pressed)
                return
            contentView.actionEvent()
        }

        function onPlayContext(pressed) { if (!pressed) return; player.playOrPause() }
        function onReplayContext(pressed) { if (!pressed) return; player.replay(); }
        function onStopContext(pressed) { if (!pressed) return; player.stop(); }
    }

    TreeHeader {
        id: treeHeader
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height * 0.12
        z: 1
    }

    ControlsFlow {
        id: treeControls
        Layout.fillWidth: true
        Layout.preferredHeight: height
        y: parent.height
        visible: contentView.treeSurface.last

        node: contentView.treeSurface.last
    }

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

    TreeNodeMenu {
        id: treeNodeMenu
    }
}
