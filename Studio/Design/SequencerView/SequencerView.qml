import QtQuick 2.15
import QtQuick.Layouts 1.15

import NodeModel 1.0
import PartitionModel 1.0
import PluginTableModel 1.0

import "./SequencerContent/"

ColumnLayout {
    enum EditMode {
        Regular,
        Brush,
        Select,
        Cut
    }

    property string moduleName: node && partition ? node.name + " - " + partition.name : "Selecting plugin"
    property int moduleIndex: -1
    property NodeModel node: null
    property PartitionModel partition: null
    property int partitionIndex: 0
    property alias player: sequencerViewFooter.player
    property int editMode: SequencerView.EditMode.Regular

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
                                list[i] = filePicker.fileUrls[i].toString().slice(7)
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

    id: sequencerView
    spacing: 0
    enabled: false
    focus: true

    onEnabledChanged: {
        // Center on reference octave
        if (enabled && contentView.yOffsetMin)
            contentView.yOffset = ((contentView.pianoView.keys - (69 - contentView.pianoView.keyOffset)) * -contentView.rowHeight) + contentView.height / 2
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_A)
            player.stop()
        else if (event.key == Qt.Key_Z)
            player.replay()
        else if (event.key == Qt.Key_E)
            player.playOrPause()
    }

    SequencerViewHeader {
        id: sequencerViewHeader
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height * 0.1
        z: 1
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.8
        Layout.preferredWidth: parent.width

        SequencerContentView {
            id: contentView
            anchors.fill: parent

            onTimelineBeginMove: player.timelineBeginMove(target)
            onTimelineMove: player.timelineMove(target)
            onTimelineEndMove: player.timelineEndMove()
        }

        SequencerContentVelocityView {
            y: parent.height - height
            width: parent.width
            height: parent.height / 2
        }
    }

    SequencerViewFooter {
        id: sequencerViewFooter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.1
        Layout.preferredWidth: parent.width
    }
}
