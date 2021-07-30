import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

import "../Default"

DefaultMenu {
    property var rootParent: null
    property var targetItem: null
    property NodeModel targetNode: null
    property int targetNodeIndex: 0

    function openMenu(newParent, node) {
        targetItem = newParent
        targetNode = node
        targetNodeIndex = node.parentNode ? node.parentNode.getChildIndex(node) : -1
        open()
    }

    function closeMenu() {
        targetItem = null
        targetNode = null
        targetNodeIndex = 0
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
        id: focusAction
        text: qsTr("Focus node")
        enabled: targetNode != plannerView.node

        onTriggered: {
            app.plannerNodeCache = targetNode
            plannerView.loadNode()
            closeMenu()
        }
    }

    Action {
        id: focusParentAction
        text: qsTr("Focus parent node")
        enabled: targetNode ? targetNode.parentNode : false

        onTriggered: {
            app.plannerNodeCache = targetNode.parentNode
            plannerView.loadNode()
            closeMenu()
        }
    }

    DefaultMenuSeparator {
        enabled: focusAction.enabled || focusParentAction.enabled
    }

    Action {
        text: qsTr("Edit name")
        enabled: true

        function setName() {
            targetNode.name = globalTextField.text
            closeMenu()
        }

        onTriggered: {
            globalTextField.open(targetNode.name, setName, function () { closeMenu() }, false, null)
        }
    }

    DefaultMenuSeparator {}

    Action {
        text: qsTr("Add child")

        onTriggered: {
            var target = targetNode
            closeMenu()
            pluginsView.prepareInsertNode(target)
        }
    }

    Action {
        text: qsTr("Add parent")
        enabled: targetNode ? targetNode.parentNode !== null : true

        onTriggered: {
            var target = targetNode
            closeMenu()
            pluginsView.prepareInsertParentNode(target)
        }
    }

    DefaultMenuSeparator {
        enabled: removeAction.enabled
    }

    Action {
        id: removeAction
        text: qsTr("Remove")

        enabled: targetNode ? targetNode.parentNode !== null : true

        onTriggered: {
            modulesView.onNodeDeleted(targetNode)
            targetNode.parentNode.remove(targetNodeIndex)
            closeMenu()
        }
    }
}
