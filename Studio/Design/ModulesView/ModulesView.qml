import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

import "../Modules/Plugins"
import "../Modules/Workspaces"

Rectangle {
    function removeComponent() {
        var moduleSelectedTmp = componentSelected
        if (componentSelected === modules.count - 1)
            componentSelected = modules.count > 1 ? modules.count - 2 : 0;
        if (modules.count === 1) {
            modules.insert(1, {
                title: "New component",
                path: "qrc:/EmptyView/EmptyView.qml",
                callback: modulesViewContent.nullCallback
            })
            componentSelected = 0
        }
        modules.removeModule(moduleSelectedTmp)
    }

    function removeAllComponents() {
        modules.clear()
        modules.insert(0, {
            title: "New component",
            path: "qrc:/EmptyView/EmptyView.qml",
            callback: modulesViewContent.nullCallback
        })
        componentSelected = 0
    }

    property alias modulesViewContent: modulesViewContent
    property alias modules: modulesViewContent.modules
    property alias componentSelected: modulesViewContent.componentSelected

    function onNodeDeleted(targetNode) {
        app.scheduler.onNodeDeleted(targetNode)
        for (var i = 0; i < modules.count;) {
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
        for (var i = 0; i < modules.count;) {
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

    WorkspacesView {
        id: filePicker
    }

    Shortcut {
        sequence: "Ctrl+T"
        onActivated: {
            modules.insert(modules.count, {
                title: "New component",
                path: "qrc:/EmptyView/EmptyView.qml",
                callback: modulesViewContent.nullCallback
            })
            componentSelected = modules.count - 1
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
        sequence: "Ctrl+Shift+W"
        onActivated: {
            if (pluginsView.visible)
                pluginsView.cancelAndClose()
            removeAllComponents()
        }
    }

    Shortcut {
        sequence: "Ctrl+Tab"
        onActivated: {
            if (modules.count > 1) {
                if (componentSelected == modules.count - 1)
                    componentSelected = 0
                else
                    componentSelected += 1
            }
        }
    }

    Shortcut {
        sequence: "Ctrl+Shift+Tab"
        onActivated: {
            if (modules.count > 1) {
                if (componentSelected == 0)
                    componentSelected = modules.count - 1
                else
                    componentSelected -= 1
            }
        }
    }
}
