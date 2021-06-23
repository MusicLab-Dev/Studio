import QtQuick 2.15

import NodeModel 1.0

import "../Default"

Column {
    property NodeModel parentNode: null
    property NodeModel node: null
    readonly property bool isSelected: node == treeSurface.selectedNode

    id: nodeDelegate

    Item {
        id: nodeInstance
        width: nodeInstanceBackground.width + treeSurface.instancePadding
        height: nodeInstanceBackground.height + treeSurface.instancePadding
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: nodeInstanceBackground
            width: nodeDelegate.isSelected ? treeSurface.instanceExpandedWidth : treeSurface.instanceDefaultWidth
            height: nodeDelegate.isSelected ? treeSurface.instanceExpandedHeight : treeSurface.instanceDefaultHeight
            color: nodeDelegate.node ? nodeDelegate.node.color : "black"
            anchors.centerIn: parent

            DefaultText {
                anchors.centerIn: parent
                text: nodeDelegate.node ? nodeDelegate.node.name : "Error"
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    if (isSelected)
                        treeSurface.selectedNode = null
                    else
                        treeSurface.selectedNode = nodeDelegate.node
                }
            }
        }

        Rectangle {
            id: verticalLinkUp
            color: nodeDelegate.parentNode ? nodeDelegate.parentNode.color : "black"
            width: 3
            anchors.top: parent.top
            anchors.bottom: nodeInstanceBackground.top
            anchors.horizontalCenter: parent.horizontalCenter
            visible: nodeDelegate.parentNode
        }

        Rectangle {
            id: verticalLinkDown
            color: nodeDelegate.node ? nodeDelegate.node.color : "black"
            anchors.top: nodeInstanceBackground.bottom
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: 3
            visible: childrenRepeater.count
        }
    }

    Rectangle {
        id: horizontalLinkDown
        color: verticalLinkDown.color
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: childrenRow.leftMargin
        anchors.rightMargin: childrenRow.rightMargin
        height: 3
        visible: childrenRepeater.count > 1
        // When visible is not turned off the tree is perfectly symetric (on selection) but I don't know why
    }

    Row {
        property real leftMargin: 0
        property real rightMargin: 0

        id: childrenRow
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            id: childrenRepeater
            model: nodeDelegate.node

            delegate: Loader {
                source: "qrc:/Tree/TreeNodeDelegate.qml"

                onLoaded: {
                    item.node = nodeInstance.instance
                    item.parentNode = nodeDelegate.node
                    if (index === 0) {
                        childrenRow.leftMargin = Qt.binding(function() {
                            return item.width / 2
                        })
                    } else if (index === childrenRepeater.count - 1) {
                        childrenRow.rightMargin = Qt.binding(function() {
                            return item.width / 2
                        })
                    }
                }
            }
        }
    }
}
