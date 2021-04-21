import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Menu {
    property var rootParent: null
    property var targetItem: null
    property NodeModel targetNode: null
    property NodeModel cachedNode: null
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
        cachedNode = null
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

    id: pluginAddMenu

    Action {
        text: qsTr("Add child")

        onTriggered: {
            pluginsView.open(
                function() {
                    // @todo add loadExternalInputs into 'add'
                    cachedNode = targetNode.add(pluginsView.selectedPath)
                    if (cachedNode === null)
                        closeMenu();
                    else if (cachedNode.needSingleExternalInput() || cachedNode.needMultipleExternalInputs()) {
                        filePicker.open(cachedNode.needMultipleExternalInputs(),
                            function() {
                                var list = []
                                for (var i = 0; i < filePicker.fileUrls.length; ++i)
                                    list[i] = filePicker.fileUrls[i].toString().slice(7)
                                cachedNode.loadExternalInputs(list)
                                closeMenu()
                            },
                            function() {
                                targetNode.remove(targetNode.count - 1)
                                closeMenu()
                            }
                        )
                    }
                },
                function() {
                    closeMenu()
                }
            )
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

    Action {
        text: qsTr("Remove")

        enabled: targetNode ? targetNode.parentNode !== null : true

        onTriggered: {
            modulesView.onNodeDeleted(targetNode)
            targetNode.parentNode.remove(targetNodeIndex)
            closeMenu()
        }
    }
}
