import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Plugins"
import "../Workspaces"
import "../Settings"
import "../Boards"

Rectangle {
    function closeAllPopups() {
        workspacesView.cancelAndClose()
        pluginsView.cancelAndClose()
        boardsView.close()
    }

    function addModule(module) {
        closeAllPopups()
        modules.append(module)
        selectedModule = modules.count - 1
    }

    function removeModule(at) {
        var oldCount = modules.count
        if (at < 0)
            return
        var item = getModule(at)
        closeAllPopups()
        if (item == getModule(at))
            modules.remove(at, 1)
        if (selectedModule >= modules.count)
            selectedModule = modules.count - 1
    }

    function removeSelectedModule() {
        removeModule(selectedModule)
    }

    function removeAllModules() {
        closeAllPopups()
        modules.clear()
        selectedModule = -modulesContent.staticTabCount
    }

    function addNewSequencer() {
        addModule({
            path: "qrc:/Sequencer/SequencerView.qml",
            callback: sequencerNewPartitionNodeCallback
        })
    }

    function addSequencerWithExistingPartition(targetNode, targetPartitionIndex) {
        app.partitionNodeCache = targetNode
        app.partitionIndexCache = targetPartitionIndex
        addModule({
            path: "qrc:/Sequencer/SequencerView.qml",
            callback: sequencerPartitionNodeCallback
        })
    }

    function getModule(idx) {
        return modulesContent.getModule(idx)
    }

    function onNodeDeleted(targetNode) {
        app.scheduler.onNodeDeleted(targetNode)
        for (var i = 0; i < modules.count;) {
            if (!getModule(i).onNodeDeleted(targetNode))
                ++i
            else if (i < selectedModule) {
                if (i === 0)
                    changeSelectedModule(-modulesContent.staticTabCount)
                else
                    changeSelectedModule(i - 1)
            }
        }
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        app.scheduler.onNodePartitionDeleted(targetNode, targetPartitionIndex)
        for (var i = 0; i < modules.count;) {
            if (!getModule(i).onNodePartitionDeleted(targetNode, targetPartitionIndex))
                ++i
            else if (i < selectedModule) {
                if (i === 0)
                    changeSelectedModule(-modulesContent.staticTabCount)
                else
                    changeSelectedModule(i - 1)
            }
        }
    }

    function changeSelectedModule(at) {
        var idx = at
        if (selectedModule === idx)
            return
        closeAllPopups()
        if (idx >= modules.count)
            idx = modules.count - 1
        selectedModule = idx
    }

    property alias modules: modules
    property alias totalModuleCount: modulesContent.totalTabCount
    property alias selectedModule: modulesContent.selectedModule
    property alias modulesContent: modulesContent
    property alias workspacesView: workspacesView
    property alias settingsView: settingsView
    property alias boardsView: boardsView

    id: modulesView
    color: "#474747"

    Action {
        property var target: null
        id: nullCallback
    }

    Action {
        property var target: null
        id: sequencerPartitionNodeCallback
        onTriggered: target.loadPartitionNode()
    }

    Action {
        property var target: null
        id: sequencerNewPartitionNodeCallback
        onTriggered: target.loadNewPartitionNode()
    }

    ListModel {
        id: modules
    }

    ModulesContentView {
        id: modulesContent
        anchors.fill: parent
    }

    PluginsView {
        id: pluginsView
        width: parent.width * 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent
    }

    WorkspacesView {
        id: workspacesView
        width: parent.width * 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent
    }

    SettingsView {
        id: settingsView
        width: parent.width * 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent
    }

    BoardsView {
        id: boardsView
        width: parent.width * 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent
    }

    Shortcut {
        sequence: "Ctrl+T"
        onActivated: addNewSequencer()
    }

    Shortcut {
        sequence: "Ctrl+W"
        onActivated: removeSelectedModule()
    }

    Shortcut {
        sequence: "Ctrl+Shift+W"
        onActivated: removeAllModules()
    }

    Shortcut {
        sequence: "Ctrl+Tab"
        onActivated: {
            if (modulesView.selectedModule == modules.count - 1)
                changeSelectedModule(-modulesContent.staticTabCount)
            else
                changeSelectedModule(modulesView.selectedModule + 1)
        }
    }

    Shortcut {
        sequence: "Ctrl+Shift+Tab"
        onActivated: {
            if (modulesView.selectedModule == -modulesContent.staticTabCount)
                changeSelectedModule(modules.count - 1)
            else
                changeSelectedModule(modulesView.selectedModule - 1)
        }
    }
}
