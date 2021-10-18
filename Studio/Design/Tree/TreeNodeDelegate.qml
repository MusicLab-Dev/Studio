import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQml 2.15
import QtGraphicalEffects 1.15

import NodeModel 1.0
import PluginModel 1.0
import PluginTableModel 1.0
import CursorManager 1.0

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
    readonly property real radius: 2
    readonly property real space: 3

    id: nodeDelegate

    Component.onCompleted: delegateOpenAnim.restart()

    PropertyAnimation {
        id: delegateOpenAnim
        target: nodeDelegate
        property: "opacity"
        from: 0
        to: 1
        duration: 300
        easing.type: Easing.OutCubic
    }

    Item {
        id: nodeInstance
        width: nodeInstanceBackground.width + treeSurface.instancePadding
        height: nodeInstanceBackground.height + treeSurface.instancePadding
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: verticalLinkUp
            color: nodeDelegate.color
            width: 2
            anchors.top: parent.top
            anchors.bottom: nodeInstanceBackground.top
            anchors.horizontalCenter: parent.horizontalCenter
            visible: nodeDelegate.parentNode && !nodeInstanceBackground.drag.active

            Rectangle {
                id: horizontalConnector
                anchors.top: parent.top
                anchors.topMargin: -6
                x: -4
                width: 10
                height: width
                color: themeManager.backgroundColor
                radius: 2
            }
        }

        Rectangle {
            id: verticalLinkDown
            color: nodeDelegate.node ? nodeDelegate.node.color : "black"
            anchors.top: nodeInstanceBackground.bottom
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: 2
            visible: childrenRepeater.count && !nodeInstanceBackground.drag.active
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
                        treeSurface.resetSelection(false)
                    var index = treeSurface.selectionList.indexOf(nodeDelegate)
                    if (index === -1) {
                        treeSurface.addNodeToSelection(nodeDelegate)
                        nodeDelegate.isSelected = true
                    } else if (hasModifier) {
                        treeSurface.removeNodeFromSelection(nodeDelegate, index)
                        nodeDelegate.isSelected = false
                    } else
                        contentView.lastSelectedNode = nodeDelegate
                }
            }

            onPressAndHold: {
                treeNodeMenu.openMenu(nodeInstanceBackground, nodeDelegate)
                treeNodeMenu.x = mouseX
                treeNodeMenu.y = mouseY
            }

            onHoveredChanged: {
                if (containsMouse)
                    cursorManager.set(CursorManager.Type.Clickable)
                else
                    cursorManager.set(CursorManager.Type.Normal)
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
                        if (!treeSurface.dragTarget || (hover && !nodeDelegate.node.isAParent(treeSurface.dragTarget) && nodeDelegate.node !== treeSurface.dragTarget.parentNode))
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
                        treeSurface.addNodeToSelection(nodeDelegate)
                    }
                }
            }

            Rectangle {
                id: topPin
                anchors.bottom: nodeContent.top
                anchors.bottomMargin: -2
                anchors.horizontalCenter: nodeContent.horizontalCenter
                width: nodeContent.width * 0.16
                height: 6
                radius: 2
                color: nodeDelegate.color
                visible: nodeDelegate.parentNode != null
            }


            Rectangle {
                id: bottomPin
                anchors.top: nodeContent.bottom
                anchors.topMargin: -2
                anchors.horizontalCenter: nodeContent.horizontalCenter
                width: nodeContent.width * 0.16
                height: topPin.height
                radius: topPin.radius
                color: topPin.color
                visible: !noChildrenFlag
            }

            ColumnLayout {
                id: nodeContent
                anchors.fill: parent
                spacing: nodeDelegate.space

                Item {
                    Layout.preferredHeight: parent.height * 0.2
                    Layout.fillWidth: true

                    RowLayout {
                        anchors.fill: parent
                        spacing: nodeDelegate.space

                        Item {
                            id: header
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Rectangle {
                                anchors.fill: parent
                                radius: nodeDelegate.radius
                                color: nodeDelegate.isSelected ? nodeDelegate.color : themeManager.backgroundColor
                                border.width: nodeInstanceBackground.containsMouse ? 2 : 0
                                border.color: nodeDelegate.color

                                Behavior on border.width {
                                    NumberAnimation { duration: 100 }
                                }
                            }

                            DefaultText {
                                anchors.fill: parent
                                anchors.leftMargin: parent.width * 0.05
                                text: nodeDelegate.node ? nodeDelegate.node.name : ""
                                color: !nodeDelegate.isSelected ? nodeDelegate.color : themeManager.backgroundColor
                                horizontalAlignment: Text.AlignLeft
                                elide: Text.ElideRight
                                font.pixelSize: 18
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: dbMeter.width

                            Rectangle {
                                anchors.fill: parent
                                radius: nodeDelegate.radius
                                color: plannerButton.hovered ? nodeDelegate.color : themeManager.backgroundColor
                            }

                            DefaultImageButton {
                                id: plannerButton
                                anchors.centerIn: parent
                                width: height
                                height: parent.height
                                source: "qrc:/Assets/Chrono.png"
                                showBorder: false
                                scaleFactor: 0.8
                                colorDefault: nodeDelegate.color
                                colorHovered: themeManager.backgroundColor
                                colorOnPressed: nodeDelegate.pressedColor
                                hoverEnabled: true

                                onHoveredChanged: cursorManager.set(CursorManager.Type.Clickable)
                                onClicked: {
                                    if (app.project.master === nodeDelegate.node)
                                        modulesView.addNewPlannerWithMultipleNodes(app.project.master.getAllChildren())
                                    else
                                        modulesView.addNewPlanner(nodeDelegate.node)
                                }
                            }
                        }

                    }

                }

                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: nodeDelegate.space

                    Item {
                        id: plugin
                        Layout.fillHeight: true
                        Layout.preferredWidth: height

                        Rectangle {
                            anchors.fill: parent
                            radius: nodeDelegate.radius
                            color: nodeDelegate.isSelected ? nodeDelegate.color : themeManager.backgroundColor
                            border.width: nodeInstanceBackground.containsDrag ? 2 : 0
                            border.color: "white"

                            Behavior on border.width {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        PluginFactoryImage {
                            id: factoryImageButton
                            anchors.centerIn: parent
                            width: height
                            height: nodeInstanceBackground.containsMouse ? parent.height * 0.6 : parent.height * 0.55
                            name: nodeDelegate.node ? nodeDelegate.node.plugin.title : ""
                            color: !nodeDelegate.isSelected ? nodeDelegate.color : themeManager.backgroundColor
                            playing: treeView.visible && (nodeInstanceBackground.containsMouse || treeView.player.playerBase.isPlayerRunning)

                            Behavior on height {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }

                    Item {
                        id: dbMeter
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        SoundMeter {
                            id: soundMeter
                            enabled: treeView.visible
                            targetNode: nodeDelegate.node
                            visible: !nodeInstanceBackground.drag.active
                            anchors.fill: parent

                            onMutedChanged: nodeDelegate.node.muted = muted
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: horizontalLinkDown
        color: verticalLinkDown.color
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: childrenRow.leftMargin - 1
        anchors.rightMargin: childrenRow.rightMargin - 1.5
        height: 2
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
