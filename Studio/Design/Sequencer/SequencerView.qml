import QtQuick 2.15
import QtQuick.Layouts 1.15

import NodeModel 1.0
import PartitionModel 1.0
import PluginTableModel 1.0
import ActionsManager 1.0
import AudioAPI 1.0

Column {
    enum EditMode {
        Regular,
        Brush,
        Select,
        Cut
    }

    enum TweakMode {
        Regular,
        Velocity,
        Tunning,
        AfterTouch
    }

    property string moduleName: node && partition ? node.name + " - " + partition.name : "Selecting plugin"
    property int moduleIndex
    property NodeModel node: null
    property PartitionModel partition: null
    property int partitionIndex: 0
    property alias player: sequencerViewFooter.player
    property int editMode: SequencerView.EditMode.Regular
    property int tweakMode: SequencerView.TweakMode.Regular
    property alias tweaker: sequencerViewFooter.tweaker
    property bool mustCenter: false

    function onNodeDeleted(targetNode) {
        if (node === targetNode || node.isAParent(targetNode)) {
            modulesView.removeModule(moduleIndex)
            return true
        }
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        if (node === targetNode && partitionIndex === targetPartitionIndex) {
            modulesView.removeModule(moduleIndex)
            return true
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

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onPlayContext(pressed) { if (!pressed) return; player.playOrPause() }
        function onReplayContext(pressed) { if (!pressed) return; player.replay(); }
        function onStopContext(pressed) { if (!pressed) return; player.stop(); }
    }

    id: sequencerView
    spacing: 0
    enabled: false
    focus: true

    onEnabledChanged: {
        // Center on reference octave
        if (enabled && contentView.yOffsetMin) {
            if (contentView.height === 0)
                mustCenter = true
            else
                contentView.yOffset = ((contentView.pianoView.keys - (69 - contentView.pianoView.keyOffset)) * -contentView.rowHeight) + contentView.height / 2
        }
    }

    SequencerHeader {
        id: sequencerViewHeader
        width: parent.width
        height: parent.height * 0.15
        z: 1
    }

    Item {
        id: contentArea
        width: parent.width
        height: parent.height * 0.7

        SequencerContentView {
            id: contentView
            anchors.fill: parent

            // When we use loadPartitionNode, contentView.height === 0 so we need to center the view once it is updated
            onHeightChanged: {
                if (mustCenter) {
                    contentView.yOffset = ((contentView.pianoView.keys - (69 - contentView.pianoView.keyOffset)) * -contentView.rowHeight) + contentView.height / 2
                    mustCenter = false
                }
            }

            onTimelineBeginMove: player.timelineBeginMove(target)
            onTimelineMove: player.timelineMove(target)
            onTimelineEndMove: player.timelineEndMove()
            onTimelineBeginLoopMove: player.timelineBeginLoopMove()
            onTimelineEndLoopMove: player.timelineEndLoopMove()
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
        width: parent.width
        height: parent.height * 0.15
    }

    ActionsManager {
        id: actionsManager
    }

    Connections {
            target: eventDispatcher
            enabled: moduleIndex === modulesView.selectedModule

            function onUndo(pressed) { if (!pressed) return; actionsManager.undo(); contentView.pianoView.notesPlacementArea.resetSelection() }
            function onRedo(pressed) { if (!pressed) return; actionsManager.redo(); contentView.pianoView.notesPlacementArea.resetSelection() }
   }
}
