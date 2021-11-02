import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0
import PluginModel 1.0

import "../Default"

DefaultMenu {
    function openMenu(newParent, nodeDelegate) {
        targetItem = newParent
        targetNodeDelegate = nodeDelegate
        targetNode = nodeDelegate.node
        targetNodeIndex = targetNode.parentNode ? targetNode.parentNode.getChildIndex(targetNode) : -1
        open()
    }

    function closeMenu() {
        targetItem = null
        targetNodeDelegate = null
        targetNode = null
        targetNodeIndex = 0
        close()
    }

    property var rootParent: null
    property var targetItem: null
    property var targetNodeDelegate: null
    property NodeModel targetNode: null
    property int targetNodeIndex: 0

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
        text: qsTr("Open all children in planner")

        onTriggered: {
            modulesView.addNewPlannerWithMultipleNodes(targetNode.getAllChildren())
            closeMenu()
        }
    }

    DefaultMenuSeparator {
        enabled: focusAction.enabled || focusParentAction.enabled
    }

    Action {
        function setNameColor() {
            targetNode.name = globalTextField.text
            targetNode.color = globalTextField.colorPicked;
            closeMenu()
        }

        text: qsTr("Edit name")
        enabled: true

        onTriggered: {
            globalTextField.open(targetNode.name, setNameColor, function () { closeMenu() }, true, targetNode.color)
        }
    }

    Action {
        text: qsTr("Change sample")
        enabled: targetNode && (targetNode.plugin.tags & PluginModel.Tags.Sampler)

        onTriggered: {
            modulesView.workspacesView.open(true,
                function() {
                    var list = []
                    for (var i = 0; i < modulesView.workspacesView.fileUrls.length; ++i)
                        list[i] = mainWindow.urlToPath(modulesView.workspacesView.fileUrls[i].toString())
                    if (app.currentPlayer)
                        app.currentPlayer.pause()
                    targetNode.plugin.setExternalInputs(list)
                },
                function() {}
            )
        }
    }

    DefaultMenuSeparator {}

    Action {
        text: qsTr("Add child")
        enabled: targetNodeDelegate ? !targetNodeDelegate.noChildrenFlag : false

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

    Action {
        text: qsTr("Duplicate (only plugin)")
        enabled: true

        onTriggered: {
            targetNode.duplicate()
            closeMenu()
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
