import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Column {
    property NodeModel node: null
    property int recursionIndex: 0
    property int index: index

    id: delegate
    width: nodeView.width

    Item {
        width: nodeView.width
        height: playlistViewContentNodeDelegatePlugin.height

        Rectangle {
            x: nodeView.linkSpacing + delegate.recursionIndex * (nodeView.linkWidth + nodeView.linkSpacing)
            y: playlistViewContentNodeDelegatePlugin.height - 12
            width: nodeView.linkWidth
            height: delegate.height - playlistViewContentNodeDelegatePlugin.height - 24
            visible: delegate.node ? delegate.node.count : false
            color: delegate.node ? delegate.node.color : "black"
        }

        PlaylistViewContentNodeDelegatePlugin {
            id: playlistViewContentNodeDelegatePlugin
            width: nodeView.headerPluginWidth
            height: Math.max(dataColumn.height, nodeView.rowHeight)
        }

        Column {
            id: dataColumn
            x: nodeView.headerPluginWidth
            width: nodeView.width - nodeView.headerPluginWidth

            PlaylistViewContentNodeDelegateControls {
                model: delegate.node ? delegate.node.controls : null
            }

            PlaylistViewContentNodeDelegatePartitions {
                model: delegate.node ? delegate.node.partitions : null
            }
        }
    }

    Repeater {
        model: delegate.node

        delegate: Loader {
            source: "qrc:/PlaylistView/PlaylistViewContent/PlaylistViewContentNodeDelegate.qml"

            onLoaded: {
                item.node = nodeInstance.instance
                item.recursionIndex = delegate.recursionIndex + 1
            }
        }
    }
}