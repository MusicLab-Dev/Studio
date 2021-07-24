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
        text: qsTr("Open in planner")

        onTriggered: {
            modulesView.addNewPlanner(targetNode)
            closeMenu()
        }
    }

    Action {
        id: focusSelectionAction
        enabled: contentView.treeSurface.selectionCount > 1
        text: qsTr("Open selection in planner")

        onTriggered: {
            var nodes = []
            for (var i = 0; i < contentView.treeSurface.selectionList.length; ++i)
                nodes.push(contentView.treeSurface.selectionList[i].node)
            modulesView.addNewPlannerWithMultipleNodes(nodes)
            closeMenu()
        }
    }

    Action {
        id: focusAllChildrenAction
        text: qsTr("Open all chilren in planner")

        onTriggered: {
            modulesView.addNewPlannerWithMultipleNodes(targetNode.getAllChildren())
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
            globalTextField.open(targetNode.name, setName, function () { closeMenu() })
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
