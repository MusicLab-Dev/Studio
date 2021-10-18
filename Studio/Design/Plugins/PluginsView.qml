import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Default"
import "../Common"

import NodeModel 1.0
import PluginTableModel 1.0
import PluginModel 1.0
import ThemeManager 1.0

Item {

    function open(accepted, canceled) {
        acceptedCallback = accepted
        canceledCallback = canceled
        selectedPath = ""
        visible = true
        openAnim.restart()
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

    function tagsToColor(tags) {
        if (tags & PluginModel.Tags.Instrument) {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Blue, blueColorIndex++)
        } else if (tags & PluginModel.Tags.Effect) {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Red, redColorIndex++)
        } else {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Green, greenColorIndex++)
        }
    }

    property int redColorIndex: 0
    property int greenColorIndex: 0
    property int blueColorIndex: 0

    property var acceptedCallback: function() {}
    property var canceledCallback: function() {}

    property int currentFilter: 0
    property string selectedPath: ""

    id: pluginsView
    visible: false

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: pluginsWindow; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: shadow; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: background; property: "opacity"; from: 0.1; to: 0.5; duration: 300; easing.type: Easing.Linear }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: themeManager.backgroundColor
        opacity: 0.5
    }

    DropShadow {
        id: shadow
        anchors.fill: pluginsWindow
        horizontalOffset: 4
        verticalOffset: 4
        radius: 6
        samples: 17
        color: "#80000000"
        source: pluginsWindow
    }

    ContentPopup {
        id: pluginsWindow

        DefaultText {
            id: pluginsViewTitle
            x: (pluginsForeground.width + (parent.width - pluginsForeground.width) / 2) - width / 2
            y: height
            text: qsTr("Plugins")
            color: "lightgrey"
            font.pointSize: 34
        }

        TextRoundedButton {
            id: pluginsViewCloseButtonText
            text: qsTr("Close")
            anchors.top: pluginsWindow.top
            anchors.topMargin: 30
            anchors.right: pluginsWindow.right
            anchors.rightMargin: 30

            onReleased: pluginsView.cancelAndClose()
        }

        PluginsForeground {
            id: pluginsForeground
            anchors.left: pluginsWindow.left
            anchors.top: pluginsWindow.top
            width: Math.max(parent.width * 0.2, 350)
            height: pluginsWindow.height
        }

        PluginsContentArea {
            id: pluginsContentArea
            anchors.top: pluginsViewTitle.top
            anchors.topMargin: pluginsViewTitle.height * 1.6
            anchors.left: pluginsForeground.right
            anchors.right: pluginsWindow.right
            anchors.bottom: pluginsWindow.bottom
            anchors.margins: pluginsWindow.width * 0.05
        }
    }


}
