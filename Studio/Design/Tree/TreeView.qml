import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"

ColumnLayout {
    property string moduleName: "Project"
    property int moduleIndex

    function onNodeDeleted(targetNode) {
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        return false
    }

    id: treeView
    focus: true

    spacing: 0

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
        visible: contentView.treeSurface.selectedNode

        model: contentView.treeSurface.selectedNode ? contentView.treeSurface.selectedNode.plugin : null
        controlsColor: contentView.treeSurface.selectedNode ? contentView.treeSurface.selectedNode.color : "black"
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
