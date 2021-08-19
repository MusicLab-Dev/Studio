import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0
import NodeModel 1.0
import PartitionModel 1.0

import "../Default"

DefaultMenu {
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

    id: nodeMenu

    Action {
        id: sequencerAction
        text: qsTr("Open in sequencer")

        onTriggered: {
            modulesView.addSequencerWithExistingPartition(targetNode, targetPartitionIndex)
            closeMenu()
        }
    }

    DefaultMenuSeparator {}

    Action {
        text: qsTr("Edit name")
        enabled: true

        function setName() {
            targetPartition.name = globalTextField.text
            closeMenu()
        }

        onTriggered: {
            globalTextField.open(targetPartition.name, setName, function () { closeMenu() }, false, null);
        }
    }

    DefaultMenuSeparator {}

    Action {
        id: duplicateAction
        text: qsTr("Duplicate")

        onTriggered: {
            targetNode.partitions.duplicate(targetPartitionIndex)
            closeMenu()
        }
    }

    Action {
        id: removeAction
        text: qsTr("Remove")

        onTriggered: {
            modulesView.onNodePartitionDeleted(targetNode, targetPartitionIndex)
            targetNode.partitions.remove(targetPartitionIndex)
            closeMenu()
        }
    }
}
