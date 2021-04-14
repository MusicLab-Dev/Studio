import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

import "../Modules/Plugins"

Rectangle {
    function removeComponent() {
        var moduleSelectedTmp = componentSelected
        if (componentSelected === modules.count - 2)
            componentSelected = modules.count - 3
        if (modules.count === 2) {
            modules.insert(1, {
                title: "New component",
                path: "qrc:/EmptyView/EmptyView.qml",
                callback: modulesViewContent.nullCallback
            })
            componentSelected = 0
        }
        modules.removeModule(moduleSelectedTmp)
    }

    property alias modulesViewContent: modulesViewContent
    property alias modules: modulesViewContent.modules
    property alias componentSelected: modulesViewContent.componentSelected

    function onNodeDeleted(targetNode) {
        app.scheduler.onNodeDeleted(targetNode)
        for (var i = 0; i < (modules.count - 1);) {
            if (!modulesViewContent.getModule(i).onNodeDeleted(targetNode))
                ++i
            else if (i < componentSelected) {
                if (i === 0)
                    componentSelected = 0
                else
                    componentSelected = i - 1
            }
        }
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        app.scheduler.onNodePartitionDeleted(targetNode, targetPartitionIndex)
        for (var i = 0; i < (modules.count - 1);) {
            if (!modulesViewContent.getModule(i).onNodePartitionDeleted(targetNode, targetPartitionIndex))
                ++i
            else if (i < componentSelected) {
                if (i === 0)
                    componentSelected = 0
                else
                    componentSelected = i - 1
            }
        }
    }

    id: modulesView
    color: "#474747"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ModulesViewContent {
            id: modulesViewContent
            Layout.preferredHeight: parent.height * 1
            Layout.preferredWidth: parent.width
            // add min / max values
        }
    }

    PluginsView {
        id: pluginsView
        width: parent.width * 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent
    }

    FileDialog {
        property var acceptedCallback: null
        property var canceledCallback: null

        function openDialog(multiple, accepted, canceled) {
            acceptedCallback = accepted
            canceledCallback = canceled
            selectMultiple = multiple
            open()
        }

        function acceptAndClose() {
            acceptedCallback()
            close()
        }

        function cancelAndClose() {
            canceledCallback()
            close()
        }

        id: filePicker
        selectFolder: false

        onAccepted: acceptAndClose()
        onRejected: cancelAndClose()

    }

    Shortcut {
        sequence: "Ctrl+T"
        onActivated: {
            modules.insert(modules.count - 1, {
                title: "New component",
                path: "qrc:/EmptyView/EmptyView.qml",
                callback: modulesViewContent.nullCallback
            })
            componentSelected = modules.count - 2
        }
    }

    Shortcut {
        sequence: "Ctrl+W"
        onActivated: {
            if (pluginsView.visible)
                pluginsView.cancelAndClose()
            removeComponent()
        }
    }


    Shortcut {
        sequence: "Ctrl+Tab"
        onActivated: {
            if (modules.count != 2) {
                if (componentSelected == modules.count - 2)
                    componentSelected = 0
                else
                    componentSelected += 1
            }
        }
    }
}
