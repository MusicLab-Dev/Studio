import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Column {
    property NodeModel node: null
    property int recursionIndex: 0

    id: nodeDelegate
    width: nodeView.width

    Item {
        id: nodeHeader
        width: nodeView.width
        height: Math.max(dataColumn.height, contentView.rowHeight)

        Rectangle {
            x: nodeView.linkSpacing + nodeDelegate.recursionIndex * (nodeView.linkWidth + nodeView.linkSpacing)
            y: pluginHeader.height - 12
            width: nodeView.linkWidth
            height: nodeDelegate.height - pluginHeader.height - 24
            visible: nodeRepeater.count
            color: nodeDelegate.node ? nodeDelegate.node.color : "black"
        }

        PlaylistContentPluginHeader {
            id: pluginHeader
            width: nodeView.pluginHeaderWidth
            height: nodeHeader.height
        }

        Column {
            id: dataColumn
            x: nodeView.pluginHeaderWidth
            width: nodeView.dataHeaderAndContentWidth

            PlaylistContentControls {
                model: nodeDelegate.node ? nodeDelegate.node.controls : null
            }

            PlaylistContentPartitions {
                model: nodeDelegate.node ? nodeDelegate.node.partitions : null
            }
        }
    }

    Repeater {
        id: nodeRepeater
        model: nodeDelegate.node

        delegate: Loader {
            source: "qrc:/PlaylistView/PlaylistContent/PlaylistContentNodeDelegate.qml"

            onLoaded: {
                item.node = nodeInstance.instance
                item.recursionIndex = nodeDelegate.recursionIndex + 1
            }
        }
    }
}