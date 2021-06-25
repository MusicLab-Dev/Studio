import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0
import PluginTableModel 1.0

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
        text: qsTr("Edit name")
        enabled: true

        function setName() {
            targetNode.name = globalTextField.text;
        }

        onTriggered: globalTextField.open(targetNode.name, setName);
    }

    DefaultMenuSeparator {}

    Action {
        text: qsTr("Add child")

        onTriggered: {
            var target = targetNode
            closeMenu()
            pluginsView.open(
                // On plugin selection accepted
                function() {
                    var externalInputType = pluginTable.getExternalInputType(pluginsView.selectedPath)
                    if (externalInputType === PluginTableModel.None) {
                        // Add the node
                        if (app.currentPlayer)
                            app.currentPlayer.pause()
                        if (target.add(pluginsView.selectedPath) === null)
                            console.log("Couldn't create node")
                    } else {
                        modulesView.workspacesView.open(externalInputType === PluginTableModel.Multiple,
                            // On external inputs selection accepted
                            function() {
                                // Format the external input list
                                var list = []
                                for (var i = 0; i < modulesView.workspacesView.fileUrls.length; ++i)
                                    list[i] = mainWindow.urlToPath(modulesView.workspacesView.fileUrls[i].toString())
                                // Add the node with external inputs
                                if (app.currentPlayer)
                                    app.currentPlayer.pause()
                                if (target.addExternalInputs(pluginsView.selectedPath, list) === null)
                                    console.log("Couldn't create node")
                            },
                            // On external inputs selection canceled
                            function() {
                            }
                        )
                    }
                },
                // On plugin selection canceled
                function() {
                }
            )
        }
    }

    Action {
        text: qsTr("Add parent")
        enabled: targetNode ? targetNode.parentNode !== null : true

        onTriggered: {
            var target = targetNode
            closeMenu()
            pluginsView.open(
                // On plugin selection accepted
                function() {
                    var externalInputType = pluginTable.getExternalInputType(pluginsView.selectedPath)
                    if (externalInputType === PluginTableModel.None) {
                        // Add the node
                        if (app.currentPlayer)
                            app.currentPlayer.pause()
                        if (target.addParent(pluginsView.selectedPath) === null)
                            console.log("Couldn't create node")
                    } else {
                        modulesView.workspacesView.open(externalInputType === PluginTableModel.Multiple,
                            // On external inputs selection accepted
                            function() {
                                // Format the external input list
                                var list = []
                                for (var i = 0; i < modulesView.workspacesView.fileUrls.length; ++i)
                                    list[i] = mainWindow.urlToPath(modulesView.workspacesView.fileUrls[i].toString())
                                // Add the node with external inputs
                                if (app.currentPlayer)
                                    app.currentPlayer.pause()
                                if (target.addParentExternalInputs(pluginsView.selectedPath, list) === null)
                                    console.log("Couldn't create node")
                            },
                            // On external inputs selection canceled
                            function() {
                            }
                        )
                    }
                },
                // On plugin selection canceled
                function() {
                }
            )
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
