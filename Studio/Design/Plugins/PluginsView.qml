import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

import NodeModel 1.0
import PluginTableModel 1.0

PluginsBackground {
    function open(accepted, canceled) {
        acceptedCallback = accepted
        canceledCallback = canceled
        selectedPath = ""
        visible = true
    }

    function acceptAndClose(path) {
        var accepted = acceptedCallback
        selectedPath = path
        visible = false
        acceptedCallback = null
        canceledCallback = null
        if (accepted)
            accepted()
    }

    function cancelAndClose() {
        var canceled = canceledCallback
        visible = false
        acceptedCallback = null
        canceledCallback = null
        if (canceled)
            canceled()
    }

    function prepareInsertNode(target) {
        open(
            // On plugin selection accepted
            function() {
                var externalInputType = pluginTable.getExternalInputType(pluginsView.selectedPath)
                if (externalInputType === PluginTableModel.None) {
                    // Add the node
                    if (app.currentPlayer)
                        app.currentPlayer.pause()
                    if (!target.add(pluginsView.selectedPath))
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
                            if (!target.addExternalInputs(pluginsView.selectedPath, list))
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

    function prepareInsertParentNode(target) {
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

    property var acceptedCallback: function() {}
    property var canceledCallback: function() {}

    property int currentFilter: 0
    property string selectedPath: ""

    id: pluginsView
    visible: false

    PluginsViewTitle {
        id: pluginsViewTitle
        x: (pluginsForeground.width + (parent.width - pluginsForeground.width) / 2) - width / 2
        y: height
    }

    TextRoundedButton {
        id: pluginsViewCloseButtonText
        text: "Close"
        x: pluginsView.width - width - height
        y: height

        onReleased: pluginsView.cancelAndClose()
    }

    PluginsForeground {
        id: pluginsForeground
        x: parent.parent.x
        y: parent.parent.y
        width: Math.max(parent.width * 0.2, 350)
        height: parent.height
    }

    PluginsContentArea {
        id: pluginsContentArea
        anchors.top: pluginsViewTitle.bottom
        anchors.left: pluginsForeground.right
        anchors.right: pluginsView.right
        anchors.bottom: pluginsView.bottom
        anchors.margins: parent.width * 0.05
    }
}
