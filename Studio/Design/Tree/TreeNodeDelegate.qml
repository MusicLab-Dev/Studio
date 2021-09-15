import QtQuick 2.15
import QtQml 2.15

import NodeModel 1.0
import PluginModel 1.0
import PluginTableModel 1.0

import "../Default"
import "../Common"

Column {
    property NodeModel parentNode: null
    property NodeModel node: null
    property bool isSelected: false
    property bool inMultipleSelection: false

    // Flags
    readonly property bool noChildrenFlag: node ? node.plugin.flags & PluginModel.Flags.NoChildren : false

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

            Rectangle {
                y: parent.height - 5 - (parent.height / 25) * (treeSurface.animationUpdateCount % 25)
                x: -5
                width: 11
                height: 11
                radius: 5
                color: verticalLinkUp.color
                visible: treeView.player.isPlayerRunning
            }
        }

        Rectangle {
            id: verticalLinkDown
            color: nodeDelegate.node ? nodeDelegate.node.color : "black"
            anchors.top: nodeInstanceBackground.bottom
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: 3
            visible: childrenRepeater.count && !nodeInstanceBackground.drag.active

            Rectangle {
                y: parent.height - 5 - (parent.height / 25) * (treeSurface.animationUpdateCount % 25)
                x: -5
                width: 11
                height: 11
                radius: 5
                color: verticalLinkDown.color
                visible: treeView.player.isPlayerRunning
            }
        }

        SoundMeter {
            id: soundMeter
            enabled: treeView.visible
            // color: nodeInstanceBackgroundRect.border.color
            targetNode: nodeDelegate.node
            visible: !nodeInstanceBackground.drag.active
            anchors.top: nodeInstanceBackground.top
            anchors.topMargin: 10
            anchors.bottom: nodeInstanceBackground.bottom
            anchors.bottomMargin: 10
            anchors.left: nodeInstanceBackground.right
            anchors.leftMargin: nodeInstanceBackground.width * 0.05
            width: height / 4
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
            drag.target: nodeDelegate.node && nodeDelegate.node.parentNode ? nodeInstanceBackground : null
            drag.smoothed: true
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2
            opacity: drag.active ? 0.75 : 1

            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    treeNodeMenu.openMenu(nodeInstanceBackground, nodeDelegate)
                    treeNodeMenu.x = mouseX
                    treeNodeMenu.y = mouseY
                } else {
                    var hasModifier = mouse.modifiers & Qt.ControlModifier
                    if (!hasModifier)
                        treeSurface.resetSelection()
                    var index = treeSurface.selectionList.indexOf(nodeDelegate)
                    if (index === -1) {
                        contentView.lastSelectedNode = nodeDelegate
                        treeSurface.selectionList.push(nodeDelegate)
                        ++treeSurface.selectionCount
                        nodeDelegate.isSelected = true
                        last = nodeDelegate.node
                        treeControls.open(last)
                    } else if (hasModifier) {
                        treeSurface.selectionList.splice(index, 1)
                        --treeSurface.selectionCount
                        nodeDelegate.isSelected = false
                        if (contentView.lastSelectedNode == nodeDelegate)
                            contentView.lastSelectedNode = null
                    } else
                        contentView.lastSelectedNode = nodeDelegate
                }
            }

            onPressAndHold: {
                treeNodeMenu.openMenu(nodeInstanceBackground, nodeDelegate)
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
                        if (!treeSurface.dragTarget || (hover && !nodeDelegate.node.isAParent(treeSurface.dragTarget)))
                            nodeInstanceBackground.validDrag = true
                        else
                            nodeInstanceBackground.validDrag = false
                        nodeInstanceBackground.containsDrag = hover
                    }
                }

                function onTargetDropped() {
                    if (nodeInstanceBackground.containsDrag) {
                        nodeInstanceBackground.containsDrag = false
                        treeSurface.processNodeDrop(nodeInstanceBackground.validDrag, nodeDelegate.node)
                    }
                }

                function onTargetPluginDropped() {
                    if (!nodeInstanceBackground.containsDrag)
                        return
                    nodeInstanceBackground.containsDrag = false
                    var pluginPath = treeSurface.dragTargetPlugin
                    var externalInputType = pluginTable.getExternalInputType(pluginPath)
                    if (externalInputType === PluginTableModel.None) {
                        // Add the node
                        if (app.currentPlayer)
                            app.currentPlayer.pause()
                        nodeDelegate.node.add(pluginPath)
                    } else {
                        modulesView.workspacesView.open(externalInputType === PluginTableModel.Multiple,
                            // On external inputs selection accepted
                            function() {
                                // Format the external input list
                                var list = []
                                for (var i = 0; i < modulesView.workspacesView.fileUrls.length; ++i)
                                    list[i] = mainWindow.urlToPath(modulesView.workspacesView.fileUrls[i].toString())
                                // Add the node with a partition and external inputs
                                if (app.currentPlayer)
                                    app.currentPlayer.pause()
                                nodeDelegate.node.addExternalInputs(pluginPath, list)
                            },
                            // On external inputs selection canceled
                            function() {}
                        )
                    }
                }
            }

            Connections {
                target: treeSurface
                enabled: treeSurface.selectionActive

                function onSelectionFinished(from, to) {
                    var min = nodeInstanceBackground.mapToItem(treeSurface, 0, 0)
                    var max = nodeInstanceBackground.mapToItem(treeSurface, nodeInstanceBackground.width, nodeInstanceBackground.height)
                    if (from.x <= min.x && from.y <= min.y && to.x >= max.x && to.y >= max.y) {
                        nodeDelegate.isSelected = true
                        treeSurface.selectionList.push(nodeDelegate)
                        ++treeSurface.selectionCount
                    }
                }
            }


            Rectangle {
                width: parent.width * 0.6
                height: parent.height * 0.4
                color: Qt.lighter(themeManager.foregroundColor, 1.2)
                anchors.horizontalCenter: parent.horizontalCenter
                y: - height / 2
                radius: 30

                Item {
                    height: parent.height * 0.5
                    width: parent.width
                    anchors.top: parent.top

                    DefaultText {
                        anchors.fill: parent
                        text: nodeDelegate.node ? nodeDelegate.node.plugin.title : qsTr("Error")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: nodeDelegate.accentColor
                        fontSizeMode: Text.Fit
                        font.pointSize: 8
                        elide: Text.ElideRight
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
                id: nodeName
                anchors.top: parent.top
                anchors.topMargin: nodeInstanceBackgroundRect.border.width * 2
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9
                height: parent.height * 0.45
                text: nodeDelegate.node ? nodeDelegate.node.name : qsTr("Error")
                color: nodeDelegate.accentColor
                fontSizeMode: Text.Fit
                font.pointSize: 20
                elide: Text.ElideRight
            }

            DefaultImageButton {
                anchors.left: parent.left
                anchors.leftMargin: nodeInstanceBackgroundRect.border.width * 2
                anchors.verticalCenter: factoryImageButton.verticalCenter
                width: factoryImageButton.height
                height: factoryImageButton.height
                source: "qrc:/Assets/Plus.png"
                showBorder: false
                scaleFactor: 1
                colorDefault: nodeDelegate.accentColor
                colorHovered: nodeDelegate.hoveredColor
                colorOnPressed: nodeDelegate.pressedColor
                visible: !nodeDelegate.noChildrenFlag

                onClicked: pluginsView.prepareInsertNode(nodeDelegate.node)
            }

            PluginFactoryImageButton {
                id: factoryImageButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: nodeName.bottom
                anchors.topMargin: nodeInstanceBackgroundRect.border.width
                anchors.bottom: parent.bottom
                anchors.bottomMargin: nodeInstanceBackgroundRect.border.width * 2
                width: height
                name: nodeDelegate.node ? nodeDelegate.node.plugin.title : ""
                colorDefault: nodeDelegate.accentColor
                colorHovered: nodeDelegate.hoveredColor
                colorOnPressed: nodeDelegate.pressedColor
                scaleFactor: 1
                playing: hovered || (treeView.visible && treeView.player.isPlayerRunning)

                onClicked: {
                    treeNodeMenu.openMenu(nodeInstanceBackground, nodeDelegate)
                    treeNodeMenu.x = pressX
                    treeNodeMenu.y = pressY
                }
            }

            DefaultImageButton {
                readonly property bool isMuted: nodeDelegate.node ? nodeDelegate.node.muted : false

                anchors.right: parent.right
                anchors.rightMargin: nodeInstanceBackgroundRect.border.width * 2
                anchors.verticalCenter: factoryImageButton.verticalCenter
                width: factoryImageButton.height
                height: factoryImageButton.height
                source: isMuted ? "qrc:/Assets/Muted.png" : "qrc:/Assets/Unmuted.png"
                showBorder: false
                scaleFactor: 1
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
        anchors.leftMargin: childrenRow.leftMargin - 1.5
        anchors.rightMargin: childrenRow.rightMargin - 1.5
        height: 3
        visible: childrenRepeater.count > 1
        // When visible is not turned off the tree is perfectly symetric (on selection) but I don't know why

        Rectangle {
            x: -5 + (parent.width / (2 * 25)) * (treeSurface.animationUpdateCount % 25)
            y: -5
            width: 11
            height: 11
            radius: 5
            color: horizontalLinkDown.color
            visible: treeView.player.isPlayerRunning
        }

        Rectangle {
            x: parent.width - 5 - (parent.width / (2 * 25)) * (treeSurface.animationUpdateCount % 25)
            y: -5
            width: 11
            height: 11
            radius: 5
            color: horizontalLinkDown.color
            visible: treeView.player.isPlayerRunning
        }
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
