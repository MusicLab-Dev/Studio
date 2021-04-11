import QtQuick 2.15
import QtQuick.Layouts 1.15

import NodeModel 1.0
import PartitionModel 1.0

ColumnLayout {
    property int moduleIndex: -1
    property NodeModel node: null
    property PartitionModel partition: null
    property int partitionIndex: 0
    property alias player: sequencerViewFooter.player

    function loadNewPartitionNode() {
        pluginsView.open(
            function() {
                node = app.project.master.addPartitionNode(pluginsView.selectedPath)
                partitionIndex = 0
                if (node === null) {
                    modules.remove(moduleIndex)
                    return
                }
                if (node.needSingleExternalInput() || node.needMultipleExternalInputs()) {
                    filePicker.openDialog(node.needMultipleExternalInputs(),
                        function() {
                            var str = filePicker.fileUrl.toString().slice(7)
                            node.loadExternalInputs(str)
                            partition = node.partitions.getPartition(partitionIndex)
                            sequencerView.enabled = true
                        },
                        function() {
                            app.project.master.remove(app.project.master.count - 1)
                            modulesView.componentSelected = moduleIndex
                            modulesView.removeComponent()
                        }
                    )
                } else {
                    partition = node.partitions.getPartition(partitionIndex)
                    sequencerView.enabled = true
                }
            },
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
    }

    id: sequencerView
    spacing: 0
    enabled: false

    SequencerViewHeader {
        id: sequencerViewHeader
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height * 0.1
        z: 1
    }

    SequencerViewContent {
        id: sequencerViewContent
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.8
        Layout.preferredWidth: parent.width
    }

    SequencerViewFooter {
        id: sequencerViewFooter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.1
        Layout.preferredWidth: parent.width
    }
}
