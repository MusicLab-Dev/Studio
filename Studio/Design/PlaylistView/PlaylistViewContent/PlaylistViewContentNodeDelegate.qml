import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Column {
    property NodeModel node: null
    property int recursionIndex: 0

    id: delegate
    width: nodeView.width

    Item {
        width: nodeView.width
        height: header.height

        Rectangle {
            x: delegate.recursionIndex * (nodeView.linkWidth + nodeView.linkSpacing)
            width: nodeView.linkWidth
            height: delegate.height
            visible: delegate.node.count
            color: "lightgrey"

            border.color: "grey"
            border.width: 1
        }

        Item {
            id: header
            width: nodeView.headerPluginWidth
            height: Math.max(dataColumn.height, nodeView.rowHeight)

            Rectangle {
                x: 1
                width: parent.width - 6
                y: 3
                height: parent.height - 6
                radius: width / 16
                color: "#00ECBA"

                Button {
                    id: addChild
                    visible: header.height > 60
                    y: 2
                    x: parent.width - width - 2
                    text: "+c"
                    width: height
                    height: 50

                    onReleased: delegate.node.add("__internal__:/Mixer")
                }

                Button {
                    id: addPartition
                    visible: header.height > 60
                    x: addChild.x - width - 2
                    y: addChild.y
                    text: "+p"
                    width: addChild.width
                    height: addChild.height

                    onReleased: {
                        delegate.node.partitions.add()
                    }
                }

                Button {
                    visible: header.height > 60
                    x: addPartition.x - width - 2
                    y: addPartition.y
                    text: "+c"
                    width: addChild.width
                    height: addChild.height

                    onReleased: {
                        delegate.node.controls.add(1)
                    }
                }
            }
        }

        Column {
            id: dataColumn
            x: nodeView.headerPluginWidth
            width: nodeView.headerDataWidth

            Repeater {
                model: delegate.node.controls

                delegate: Rectangle {
                    width: nodeView.headerDataWidth
                    height: nodeView.rowHeight
                    color: "red"
                    border.color: "grey"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Control"
                        font.pointSize: 24
                    }
                }
            }

            Repeater {
                model: delegate.node.partitions

                delegate: Rectangle {
                    width: nodeView.headerDataWidth
                    height: nodeView.rowHeight
                    color: "red"
                    border.color: "grey"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "Partition"
                        font.pointSize: 24
                    }
                }
            }
        }
    }

    Repeater {
        model: delegate.node.count

        delegate: Loader {
            source: "qrc:/PlaylistView/PlaylistViewContent/PlaylistViewContentNodeDelegate.qml"

            onLoaded: {
                item.node = delegate.node.get(index)
                item.recursionIndex = delegate.recursionIndex + 1
            }
        }
    }
}