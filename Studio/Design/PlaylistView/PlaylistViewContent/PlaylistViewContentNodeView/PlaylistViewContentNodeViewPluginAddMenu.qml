import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Menu {
    property var rootParent: null
    property var targetItem: null
    property NodeModel targetNode: null

    function openMenu(newParent, node) {
        targetItem = newParent
        targetNode = node
        open()
    }

    function closeMenu() {
        targetItem = null
        targetNode = null
        close()
    }

    Component.onCompleted: rootParent = parent

    onTargetItemChanged: {
        if (targetItem)
            parent = targetItem
        else
            parent = rootParent
    }

    id: pluginAddMenu

    Action {
        text: qsTr("Add child")

        onTriggered: {
            targetNode.add("__internal__:/Mixer")
            closeMenu()
        }
    }

    Action {
        text: qsTr("Add partition")

        onTriggered: {
            targetNode.partitions.add(qsTr("Partition ") + (targetNode.partitions.count() + 1))
            closeMenu()
        }
    }

    Action {
        text: qsTr("Add control")

        onTriggered: {
            targetNode.controls.add(1)
            closeMenu()
        }
    }
}