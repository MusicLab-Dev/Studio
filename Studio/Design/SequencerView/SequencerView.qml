import QtQuick 2.15
import QtQuick.Layouts 1.15

import NodeModel 1.0
import PartitionModel 1.0

ColumnLayout {
    property int moduleIndex: -1
    property NodeModel node: null
    property PartitionModel partition: null

    function loadNewPartitionNode() {
        pluginsView.open(
            function() {
                node = app.project.master.addPartitionNode(pluginsView.selectedPath)
                if (node === null) {
                    modules.remove(moduleIndex)
                    return
                }
                if (node.needSingleExternalInput() || node.needMultipleExternalInputs()) {
                    filePicker.openDialog(node.needMultipleExternalInputs(),
                        function() {
                            node.loadExternalInputs(filePicker.fileUrls)
                            app.scheduler.partitionNode = node
                            app.scheduler.partitionIndex = 0
                            partition = node.partitions.getPartition(0)
                            sequencerView.enabled = true
                        },
                        function() {
                            app.project.master.remove(app.project.master.count - 1)
                            modules.remove(moduleIndex)
                        }
                    )
                }
            },
            function() {
                modules.remove(moduleIndex)
            }
        )
    }

    function loadPartitionNode() {
        node = app.scheduler.partitionNode
        partition = app.scheduler.partitionNode.partitions.getPartition(app.scheduler.partitionIndex)
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
