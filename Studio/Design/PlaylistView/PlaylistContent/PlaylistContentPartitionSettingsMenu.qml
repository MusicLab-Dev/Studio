import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0
import PartitionModel 1.0

Menu {
    property var rootParent: null
    property var targetItem: null
    property NodeModel targetNode: null
    property PartitionModel targetPartition: null
    property int targetPartitionIndex: 0

    function openMenu(newParent, node, partition, partitionIndex) {
        targetItem = newParent
        targetNode = node
        targetPartition = partition
        targetPartitionIndex = partitionIndex
        open()
    }

    function closeMenu() {
        targetItem = null
        targetNode = null
        targetPartition = null
        targetPartitionIndex = 0
        close()
    }

    Component.onCompleted: rootParent = parent

    onTargetItemChanged: {
        if (targetItem)
            parent = targetItem
        else
            parent = rootParent
    }

    id: partitionAddMenu

    Action {
        text: qsTr("Edit")

        onTriggered: {
            app.partitionNodeCache = targetNode
            app.partitionIndexCache = targetPartitionIndex
            modules.insert(modules.count, {
                title: "Sequencer",
                path: "qrc:/SequencerView/SequencerView.qml",
                callback: modulesViewContent.sequencerPartitionNodeCallback
            })
            closeMenu()
        }
    }

    Action {
        text: qsTr("Remove")
        enabled: app.scheduler.partitionNode != targetNode || app.scheduler.partitionIndex != targetPartitionIndex

        onTriggered: {
            modulesView.onNodePartitionDeleted(targetNode, targetPartitionIndex)
            targetNode.partitions.remove(targetPartitionIndex)
            closeMenu()
        }
    }
}