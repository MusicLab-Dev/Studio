import QtQuick 2.15
import QtQuick.Layouts 1.15

import NodeModel 1.0
import PartitionModel 1.0
import PluginTableModel 1.0

import "./SequencerContent/"

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
    property int moduleIndex: -1
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
            modules.removeModule(moduleIndex)
            return true
        }
        return false
    }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {
        if (node === targetNode && partitionIndex === targetPartitionIndex) {
            modules.removeModule(moduleIndex)
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
                    node = app.project.master.addPartitionNode(pluginsView.selectedPath)
                    partitionIndex = 0
                    if (node === null) {
                        modulesView.componentSelected = moduleIndex
                        modulesView.removeComponent()
                    } else {
                        partition = node.partitions.getPartition(partitionIndex)
                        sequencerView.enabled = true
                    }
                } else {
                    filePicker.open(externalInputType === PluginTableModel.Multiple,
                        // On external inputs selection accepted
                        function() {
                            // Format the external input list
                            var list = []
                            for (var i = 0; i < filePicker.fileUrls.length; ++i)
                                list[i] = mainWindow.urlToPath(filePicker.fileUrls[i].toString())
                            // Add the node with a partition and external inputs
                            node = app.project.master.addPartitionNodeExternalInputs(pluginsView.selectedPath, list)
                            partitionIndex = 0
                            if (node === null) {
                                modulesView.componentSelected = moduleIndex
                                modulesView.removeComponent()
                            } else {
                                partition = node.partitions.getPartition(partitionIndex)
                                sequencerView.enabled = true
                            }
                        },
                        // On external inputs selection canceled
                        function() {
                            modulesView.componentSelected = moduleIndex
                            modulesView.removeComponent()
                        }
                    )
                }
            },
            // On plugin selection canceled
            function() {
                modulesView.componentSelected = moduleIndex
                modulesView.removeComponent()
            }
        )
    }

    function loadPartitionNode() {
        node = app.partitionNodeCache
        partitionIndex = app.partitionIndexCache
        partition = app.partitionNodeCache.partitions.getPartition(app.partitionIndexCache)
        app.partitionNodeCache = null
        app.partitionIndexCache = -1
        modulesView.componentSelected = moduleIndex
        sequencerView.enabled = true
    }

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === componentSelected

        function onPlayContext(pressed) { if (!pressed) return; if(!player.isPlayerRunning) player.play(); else player.pause(); }
        function onPauseContext(pressed) { if (!pressed) return; player.pause(); }
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

    SequencerViewHeader {
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
        }

        SequencerContentTweakView {
            visible: tweakMode === SequencerView.TweakMode.Velocity || tweakMode === SequencerView.TweakMode.Tunning
            y: tweakMode > SequencerView.TweakMode.Regular ? parent.height - height : parent.height
            width: parent.width
            height: parent.height / 2
        }
    }

    SequencerViewFooter {
        id: sequencerViewFooter
        width: parent.width
        height: parent.height * 0.15
    }
}
