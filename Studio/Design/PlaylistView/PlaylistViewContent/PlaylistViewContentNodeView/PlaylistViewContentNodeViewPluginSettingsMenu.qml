import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Menu {
    property var rootParent: null
    property var targetItem: null
    property NodeModel targetNode: null
    property int targetNodeIndex: 0

    function openMenu(newParent, node, nodeIndex) {
        targetItem = newParent
        targetNode = node
        targetNodeIndex = nodeIndex
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
        text: qsTr("Remove")

        enabled: targetNode ? targetNode.parentNode : true

        onTriggered: {
            targetNode.parentNode.remove(targetNodeIndex)
            closeMenu()
        }
    }
}