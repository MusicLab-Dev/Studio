import QtQuick 2.15
import QtQml 2.15

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
            anchors.bottom: soundMeter.top
            anchors.horizontalCenter: parent.horizontalCenter
            visible: nodeDelegate.parentNode && !nodeInstanceBackground.drag.active
        }

        Rectangle {
            id: verticalLinkDown
            color: nodeDelegate.node ? nodeDelegate.node.color : "black"
            anchors.top: nodeInstanceBackground.bottom
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: 3
            visible: childrenRepeater.count && !nodeInstanceBackground.drag.active
        }

        Rectangle {
            id: soundMeter
            visible: !nodeInstanceBackground.drag.active
            anchors.top: parent.top
            anchors.bottom: nodeInstanceBackground.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 8
            // anchors.bottomMargin: 5
            color: themeManager.backgroundColor
            border.color: nodeInstanceBackgroundRect.border.color
            border.width: 2
            width: height / 2
        }

        MouseArea {
            property bool containsDrag: false
            property bool validDrag: false

            id: nodeInstanceBackground
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            width: treeSurface.instanceDefaultWidth
            height: treeSurface.instanceDefaultHeight
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            drag.target: nodeInstanceBackground
            drag.smoothed: true
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2
            opacity: drag.active ? 0.75 : 1

            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    treeNodeMenu.openMenu(nodeInstanceBackground, nodeDelegate.node)
                    treeNodeMenu.x = mouseX
                    treeNodeMenu.y = mouseY
                } else
                    treeSurface.selectedNode = nodeDelegate.node
            }

            onPressAndHold: {
                treeNodeMenu.openMenu(nodeInstanceBackground, nodeDelegate.node)
                treeNodeMenu.x = mouseX
                treeNodeMenu.y = mouseY
            }

            onDoubleClicked: {
                modulesView.addNewPlanner(nodeDelegate.node)
            }

            drag.onActiveChanged: {
                if (drag.active) {
                    treeSurface.startDrag(nodeDelegate.node, treeSurface.mapFromItem(nodeInstanceBackground, mouseX, mouseY))
                    parent = treeSurface
                } else {
                    treeSurface.endDrag()
                    parent = nodeInstance
                    x = Qt.binding(function() {
                        return parent.width / 2 - width / 2
                    })
                    y = Qt.binding(function() {
                        return parent.height / 2 - height / 2
                    })
                }
            }

            Connections {
                enabled: nodeInstanceBackground.drag.active
                target: nodeInstanceBackground

                function onXChanged() {
                    treeSurface.updateDrag(treeSurface.mapFromItem(nodeInstanceBackground, nodeInstanceBackground.mouseX, nodeInstanceBackground.mouseY))
                }

                function onYChanged() {
                    treeSurface.updateDrag(treeSurface.mapFromItem(nodeInstanceBackground, nodeInstanceBackground.mouseX, nodeInstanceBackground.mouseY))
                }
            }

            Connections {
                enabled: treeSurface.dragActive && !nodeInstanceBackground.drag.active
                target: treeSurface

                function onDragPointChanged() {
                    var hover = nodeInstanceBackground.contains(nodeInstanceBackground.mapFromItem(treeSurface, treeSurface.dragPoint))
                    if (nodeInstanceBackground.containsDrag !== hover) {
                        if (hover && !nodeDelegate.node.isAParent(treeSurface.dragTarget))
                            nodeInstanceBackground.validDrag = true
                        else
                            nodeInstanceBackground.validDrag = false
                        nodeInstanceBackground.containsDrag = hover
                    }
                }

                function onTargetDropped() {
                    if (nodeInstanceBackground.containsDrag) {
                        nodeInstanceBackground.containsDrag = false
                        nodeDelegate.node.moveToChildren(treeSurface.dragTarget)
                    }
                }
            }

            Rectangle {
                id: nodeInstanceBackgroundRect
                anchors.fill: parent
                radius: 15
                color: nodeInstanceBackground.containsDrag ? nodeInstanceBackground.validDrag ? nodeDelegate.lightColor : nodeDelegate.pressedColor : nodeDelegate.color
                border.color: nodeInstanceBackground.containsPress ? nodeDelegate.pressedColor : nodeDelegate.isSelected ? nodeDelegate.lightColor : nodeInstanceBackground.containsMouse ? nodeDelegate.hoveredColor : nodeDelegate.color
                border.width: 4
            }

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

            DefaultImageButton {
                anchors.left: parent.left
                y: parent.height * 0.75 - height / 2
                width: height
                height: Math.min(parent.height / 2, 50)
                source: "qrc:/Assets/Plus.png"
                showBorder: false
                scaleFactor: 1
                colorDefault: nodeDelegate.accentColor
                colorHovered: nodeDelegate.hoveredColor
                colorOnPressed: nodeDelegate.pressedColor

                onClicked: pluginsView.prepareInsertNode(nodeDelegate.node)
            }

            DefaultImageButton {
                readonly property bool isMuted: nodeDelegate.node ? nodeDelegate.node.muted : false

                anchors.right: parent.right
                y: parent.height * 0.75 - height / 2
                width: height
                height: Math.min(parent.height / 2, 50)
                source: isMuted ? "qrc:/Assets/Muted.png" : "qrc:/Assets/Unmuted.png"
                showBorder: false
                scaleFactor: 0.8
                colorDefault: nodeDelegate.accentColor
                colorHovered: nodeDelegate.hoveredColor
                colorOnPressed: nodeDelegate.pressedColor

                onReleased: nodeDelegate.node.muted = !isMuted
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

            onCountChanged: {
                if (!count) {
                    childrenRow.leftMargin = Qt.binding(function() { return 0 })
                    childrenRow.rightMargin = Qt.binding(function() { return 0 })
                }
            }

            delegate: Loader {
                source: "qrc:/Tree/TreeNodeDelegate.qml"
                focus: true

                onLoaded: {
                    focus = true
                    item.focus = true
                    item.node = nodeInstance.instance
                    item.parentNode = nodeDelegate.node
                }

                Connections {
                    target: childrenRepeater

                    function onCountChanged() {
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
}
