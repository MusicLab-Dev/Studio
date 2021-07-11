import QtQuick 2.15

Column {
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
        width: parent.width
        height: parent.height * 0.15
        z: 1
    }

    TreeContentView {
        id: contentView
        width: parent.width
        height: parent.height * 0.7
    }

    TreeFooter {
        id: treeFooter
        width: parent.width
        height: parent.height * 0.15
    }

    TreeNodeMenu {
        id: treeNodeMenu
    }
}
