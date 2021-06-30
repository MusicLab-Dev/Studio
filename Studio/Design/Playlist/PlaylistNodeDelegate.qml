import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Column {
    readonly property int nodeIndex: index
    property NodeModel node: isDelegate ? nodeInstance.instance : null
    property int recursionIndex: 0
    property bool isDelegate: false

    id: nodeDelegate
    width: nodeView.width

    Item {
        id: nodeHeader
        width: nodeView.width
        height: Math.max(dataColumn.height, contentView.rowHeight)

        Rectangle {
            x: nodeView.linkSpacing + nodeDelegate.recursionIndex * (nodeView.linkWidth + nodeView.linkSpacing)
            y: pluginHeader.height - nodeView.pluginHeaderTopPadding
            width: nodeView.linkWidth
            height: nodeDelegate.height - pluginHeader.height
            visible: nodeRepeater.count
            color: nodeDelegate.node ? nodeDelegate.node.color : "black"
        }

        PlaylistPluginHeader {
            id: pluginHeader
            width: nodeView.pluginHeaderWidth
            height: nodeHeader.height
        }

        Column {
            id: dataColumn
            x: nodeView.pluginHeaderWidth
            width: nodeView.dataHeaderAndContentWidth

            PlaylistControls {
                model: nodeDelegate.node ? nodeDelegate.node.controls : null
            }

            PlaylistPartitions {
                model: nodeDelegate.node ? nodeDelegate.node.partitions : null
            }
        }
    }

    Repeater {
        id: nodeRepeater
        model: nodeDelegate.node

        delegate: Loader {
            source: "qrc:/Playlist/PlaylistNodeDelegate.qml"

            onLoaded: {
                item.isDelegate = true
                item.recursionIndex = nodeDelegate.recursionIndex + 1
            }
        }
    }
}