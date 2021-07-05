import QtQuick 2.15

import NodeModel 1.0

import "../Default"

Column {
    property NodeModel parentNode: null
    property NodeModel node: null
    readonly property bool isSelected: node == treeSurface.selectedNode

    // Colors
    readonly property color color: node ? node.color : "black"
    readonly property color darkColor: Qt.darker(color, 1.25)
    readonly property color lightColor: Qt.lighter(color, 1.6)
    readonly property color hoveredColor: Qt.darker(color, 1.8)
    readonly property color pressedColor: Qt.darker(color, 2.2)
    readonly property color accentColor: Qt.darker(color, 1.6)

    id: nodeDelegate

    Item {
        id: nodeInstance
        width: nodeInstanceBackground.width + treeSurface.instancePadding
        height: nodeInstanceBackground.height + treeSurface.instancePadding
        anchors.horizontalCenter: parent.horizontalCenter

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

        Rectangle {
            id: nodeInstanceBackground
            width: treeSurface.instanceDefaultWidth
            height: treeSurface.instanceDefaultHeight
            radius: 15
            color: nodeDelegate.color
            border.color: nodeMouseArea.containsPress ? nodeDelegate.pressedColor : nodeDelegate.isSelected ? nodeDelegate.lightColor : nodeDelegate.hoveredColor
            border.width: nodeMouseArea.containsMouse || nodeDelegate.isSelected ? 4 : 0
            anchors.centerIn: parent

            DefaultText {
                x: 5
                y: 5
                width: parent.width - 10
                height: parent.height / 2 - 10
                text: nodeDelegate.node ? nodeDelegate.node.name : "Error"
                color: nodeDelegate.accentColor
                fontSizeMode: Text.Fit
                font.pointSize: 28
                elide: Text.ElideRight
            }

            MouseArea {
                id: nodeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: {
                    if (mouse.button === Qt.RightButton) {
                        treeNodeMenu.openMenu(nodeMouseArea, nodeDelegate.node)
                        treeNodeMenu.x = mouseX
                        treeNodeMenu.y = mouseY
                    } else
                        treeSurface.selectedNode = nodeDelegate.node
                }

                onDoubleClicked: {
                    modulesView.addNewPlanner(nodeDelegate.node)
                }
            }

            DefaultImageButton {
                x: parent.width / 2 - width / 2
                y: parent.height
                width: height
                height: treeSurface.instanceDefaultHeight / 2
                source: "qrc:/Assets/Plus.png"
                showBorder: false
                scaleFactor: 1
                colorDefault: nodeDelegate.accentColor
                colorHovered: nodeDelegate.hoveredColor
                colorOnPressed: nodeDelegate.pressedColor

                onReleased: {
                    // @todo
                }
            }
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
