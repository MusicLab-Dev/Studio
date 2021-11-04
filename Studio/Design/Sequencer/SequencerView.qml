import QtQuick 2.15
import QtQuick.Layouts 1.15

import NodeModel 1.0
import PartitionModel 1.0
import PluginTableModel 1.0
import ActionsManager 1.0
import AudioAPI 1.0

import "../Common"
import "../Help"

Item {
    enum TweakMode {
        Regular,
        Velocity,
        Tunning,
        AfterTouch
    }

    function onNodeDeleted(targetNode) {
        if (node == targetNode || node.isAParent(targetNode)) {
            modulesView.removeModule(moduleIndex)
            return true
        } else {
            actionsManager.nodeDeleted(targetNode)
        }
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        if (node === targetNode && partitionIndex === targetPartitionIndex) {
            modulesView.removeModule(moduleIndex)
            return true
        } else {
            actionsManager.nodePartitionDeleted(targetNode, targetPartitionIndex)
        }
        return false
    }

    function loadNewPartitionNode() {
        pluginsView.open(
            // On plugin selection accepted
            function() {
                var externalInputType = pluginTable.getExternalInputType(pluginsView.selectedPath)
                if (externalInputType === PluginTableModel.None) {
                    // Add the node with a partition
                    if (app.currentPlayer)
                        app.currentPlayer.pause()
                    node = app.project.master.addPartitionNode(pluginsView.selectedPath)
                    partitionIndex = 0
                    if (node === null) {
                        modulesView.removeModule(moduleIndex)
                    } else {
                        partition = node.partitions.getPartition(partitionIndex)
                        sequencerView.enabled = true
                    }
                } else {
                    modulesView.workspacesView.open(externalInputType === PluginTableModel.Multiple,
                        // On external inputs selection accepted
                        function() {
                            // Format the external input list
                            var list = []
                            for (var i = 0; i < modulesView.workspacesView.fileUrls.length; ++i)
                                list[i] = mainWindow.urlToPath(modulesView.workspacesView.fileUrls[i].toString())
                            // Add the node with a partition and external inputs
                            if (app.currentPlayer)
                                app.currentPlayer.pause()
                            node = app.project.master.addPartitionNodeExternalInputs(pluginsView.selectedPath, list)
                            partitionIndex = 0
                            if (node === null) {
                                modulesView.removeModule(moduleIndex)
                            } else {
                                partition = node.partitions.getPartition(partitionIndex)
                                sequencerView.enabled = true
                            }
                        },
                        // On external inputs selection canceled
                        function() {
                            modulesView.removeModule(moduleIndex)
                        }
                    )
                }
            },
            // On plugin selection canceled
            function() {
                modulesView.removeModule(moduleIndex)
            }
        )
    }

    function loadPartitionNode() {
        node = app.partitionNodeCache
        partitionIndex = app.partitionIndexCache
        partition = app.partitionNodeCache.partitions.getPartition(app.partitionIndexCache)
        app.partitionNodeCache = null
        app.partitionIndexCache = -1
        sequencerView.enabled = true
    }

    function changePartition(targetIndex) {
        contentView.placementArea.resetSelection()
        partitionIndex = targetIndex
        console.log("Changepartition ", targetIndex)
        partition = node.partitions.getPartition(targetIndex)
        console.debug("changePartition success!")
    }

    property string moduleName: node && partition ? node.name + " - " + partition.name : "Selecting plugin"
    property int moduleIndex
    property NodeModel node: null
    property PartitionModel partition: null
    property int partitionIndex: 0
    property alias player: sequencerViewFooter.player
    property int tweakMode: SequencerView.TweakMode.Regular
    property alias tweaker: sequencerViewFooter.tweaker
    property bool mustCenter: false

    id: sequencerView
    enabled: false
    focus: true

    onEnabledChanged: {
        // Center on reference octave
        if (enabled && contentView.yOffsetMin) {
            if (contentView.height === 0)
                mustCenter = true
            else
                contentView.centerTargetOctave()
        }
    }

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onPlayPauseContext(pressed) { if (pressed) player.playOrPause() }
        function onReplayStopContext(pressed) { if (pressed) player.replayOrStop() }
        function onReplayContext(pressed) { if (pressed) player.replay() }
        function onStopContext(pressed) { if (pressed) player.stop() }
    }

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule && contentView.placementArea.mode === PlacementArea.None

        function onUndo(pressed) {
            if (pressed) {
                actionsManager.undo()
                contentView.placementArea.resetSelection()
            }
        }

        function onRedo(pressed) {
            if (pressed) {
                actionsManager.redo()
                contentView.placementArea.resetSelection()
            }
        }
    }

    ColumnLayout {
        spacing: 0
        anchors.fill: parent

        SequencerHeader {
            id: sequencerViewHeader
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.12
            z: 1
        }

        Rectangle {
            color: "black"
            visible: sequencerControls.visible
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 1
        }

        ControlsFlow {
            id: sequencerControls
            closeable: false
            y: parent.height
            node: sequencerView.node
            Layout.fillWidth: true
            visible: requiredVisibility

            HelpArea {
                name: qsTr("Controls")
                description: qsTr("Description")
                position: HelpHandler.Position.Bottom
                externalDisplay: true
                visible: sequencerControls.requiredVisibility
            }
        }

        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            SequencerContentView {
                id: contentView
                width: parent.width
                height: parent.height
                anchors.fill: parent

                // When we use loadPartitionNode, contentView.height === 0 so we need to center the view once it is updated
                onHeightChanged: {
                    if (sequencerView.mustCenter) {
                        centerTargetOctave()
                        sequencerView.mustCenter = false
                    }
                }
            }

            SequencerContentTweakView {
                visible: tweakMode === SequencerView.TweakMode.Velocity || tweakMode === SequencerView.TweakMode.Tunning
                y: tweakMode > SequencerView.TweakMode.Regular ? parent.height - height : parent.height
                width: parent.width
                height: parent.height / 2
            }
        }

        SequencerFooter {
            id: sequencerViewFooter
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.12
        }
    }

    HelpHandler {
        id: helpHandler
    }

    ActionsManager {
        id: actionsManager
    }

    FMDebugWindow {
        node: sequencerView.node
    }
}
