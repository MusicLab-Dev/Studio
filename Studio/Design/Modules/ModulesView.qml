import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"
import "../Plugins"
import "../Workspaces"
import "../Settings"
import "../Planner"
import "../Sequencer"

Rectangle {
    enum ModuleType {
        Tree,
        Planner,
        Sequencer
    }

    function closeAllPopups() {
        workspacesView.cancelAndClose()
        pluginsView.cancelAndClose()
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

    function addNewPlanner(node) {
        var idx = getSamePlanner([node])
        if (idx === -1) {
            app.plannerNodeCache = node
            addModule({
                type: ModulesView.Planner,
                path: "qrc:/Planner/PlannerView.qml",
                callback: plannerNodeCallback
            })
        } else
            modulesView.changeSelectedModule(idx)
    }

    function addNewPlannerWithMultipleNodes(nodes) {
        var idx = getSamePlanner(nodes)
        if (idx === -1) {
            app.plannerNodesCache = nodes
            addModule({
                type: ModulesView.Planner,
                path: "qrc:/Planner/PlannerView.qml",
                callback: plannerMultipleNodesCallback
            })
        } else
            modulesView.changeSelectedModule(idx)
    }

    function addNewSequencer() {
        addModule({
            type: ModulesView.Sequencer,
            path: "qrc:/Sequencer/SequencerView.qml",
            callback: sequencerNewPartitionNodeCallback
        })
    }

    function addSequencerWithExistingPartition(targetNode, targetPartitionIndex) {
        var idx = getSameSequencer(targetNode, targetPartitionIndex)
        if (idx === -1) {
            app.partitionNodeCache = targetNode
            app.partitionIndexCache = targetPartitionIndex
            addModule({
                type: ModulesView.Sequencer,
                path: "qrc:/Sequencer/SequencerView.qml",
                callback: sequencerPartitionNodeCallback
            })
        } else {
            modulesView.changeSelectedModule(idx)
            var sequencer = modulesView.getModule(idx)
            sequencer.partitionIndex = targetPartitionIndex
            sequencer.partition = targetNode.partitions.getPartition(targetPartitionIndex)
        }
    }

    function getModule(idx) {
        return modulesContent.getModule(idx)
    }

    function getSamePlanner(nodes) {
        for (var i = 0; i < modulesContent.totalTabCount; i++) {
            var planner = getModule(i)
            if (planner instanceof PlannerView) {
                if (planner.nodeList.equals(nodes))
                    return i;
            }
        }
        return -1
    }

    function getSameSequencer(node) {
        for (var i = 0; i < modulesContent.totalTabCount; i++) {
            var sequencer = getModule(i)
            if (sequencer instanceof SequencerView) {
                if (sequencer.node != node)
                    continue;
                return i;
            }
        }
        return -1
    }

    function onNodeDeleted(targetNode) {
        app.scheduler.onNodeDeleted(targetNode)
        var i = -modulesContent.staticTabCount;
        for (; i < 0; ++i)
            getModule(i).onNodeDeleted(targetNode)
        for (i = 0; i < modules.count;) {
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
        var i = -modulesContent.staticTabCount;
        for (; i < 0; ++i)
            getModule(i).onNodePartitionDeleted(targetNode, targetPartitionIndex)
        for (i = 0; i < modules.count;) {
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

    function moveModule(from, to) {
        modulesView.modules.move(from, to, 1)
        modulesView.selectedModule = to
    }

    property alias productionPlayerBase: productionPlayerBase
    property alias modules: modules
    property alias totalModuleCount: modulesContent.totalTabCount
    property alias selectedModule: modulesContent.selectedModule
    property alias modulesContent: modulesContent
    property alias workspacesView: workspacesView
    property alias settingsView: settingsView
//    property alias boardsView: boardsView

    id: modulesView
    color: themeManager.contentColor

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

    Action {
        property var target: null
        id: plannerNodeCallback
        onTriggered: target.loadNode()
    }

    Action {
        property var target: null
        id: plannerMultipleNodesCallback
        onTriggered: target.loadMultipleNodes()
    }

    PlayerBase {
        id: productionPlayerBase
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
        anchors.fill: parent
    }

    WorkspacesView {
        id: workspacesView
        anchors.fill: parent
    }

    SettingsView {
        id: settingsView
        anchors.fill: parent
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
