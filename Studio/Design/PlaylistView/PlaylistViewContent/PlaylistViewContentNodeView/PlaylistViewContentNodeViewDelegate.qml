import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Column {
    property NodeModel node: null
    property int recursionIndex: 0

    id: nodeDelegate
    width: nodeView.width

    Item {
        width: nodeView.width
        height: playlistViewContentNodeViewDelegatePlugin.height

        Rectangle {
            x: nodeView.linkSpacing + nodeDelegate.recursionIndex * (nodeView.linkWidth + nodeView.linkSpacing)
            y: playlistViewContentNodeViewDelegatePlugin.height - 12
            width: nodeView.linkWidth
            height: nodeDelegate.height - playlistViewContentNodeViewDelegatePlugin.height - 24
            visible: nodeRepeater.count
            color: nodeDelegate.node ? nodeDelegate.node.color : "black"
        }

        PlaylistViewContentNodeViewDelegatePlugin {
            id: playlistViewContentNodeViewDelegatePlugin
            width: nodeView.headerPluginWidth
            height: Math.max(dataColumn.height, nodeView.rowHeight)
        }

        Column {
            id: dataColumn
            x: nodeView.headerPluginWidth
            width: nodeView.width - nodeView.headerPluginWidth

            PlaylistViewContentNodeViewDelegateControls {
                model: nodeDelegate.node ? nodeDelegate.node.controls : null
            }

            PlaylistViewContentNodeViewDelegatePartitions {
                model: nodeDelegate.node ? nodeDelegate.node.partitions : null
            }
        }
    }

    Repeater {
        id: nodeRepeater
        model: nodeDelegate.node

        delegate: Loader {
            source: "qrc:/PlaylistView/PlaylistViewContent/PlaylistViewContentNodeView/PlaylistViewContentNodeViewDelegate.qml"

            onLoaded: {
                item.node = nodeInstance.instance
                item.recursionIndex = nodeDelegate.recursionIndex + 1
            }
        }
    }
}