import QtQuick 2.15

Column {
    property string moduleName: "Tree"
    property int moduleIndex

    function onNodeDeleted(targetNode) {
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        return false
    }

    id: treeView
    focus: true

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
}
