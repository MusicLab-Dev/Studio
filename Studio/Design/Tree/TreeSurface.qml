import QtQuick 2.15

import NodeModel 1.0

Item {
    function startDrag(targetNode, targetPoint) {
        dragTarget = targetNode
        dragTargetPlugin = ""
        dragPoint = targetPoint
        dragActive = true
    }

    function updateDrag(targetPoint) {
        dragPoint = targetPoint
    }

    function endDrag() {
        targetDropped()
        dragActive = false
        dragTarget = null
        dragTargetPlugin = ""
        dragPoint = Qt.point(0, 0)
    }

    function startPluginDrag(pluginPath, targetPoint) {
        dragTarget = null
        dragTargetPlugin = pluginPath
        dragPoint = targetPoint
        dragActive = true
    }

    function endPluginDrag() {
        targetPluginDropped()
        dragActive = false
        dragTarget = null
        dragTargetPlugin = ""
        dragPoint = Qt.point(0, 0)
    }

    function beginSelection(targetPoint) {
        resetSelection()
        selectionActive = true
        selectionFrom = targetPoint
        selectionTo = targetPoint
    }

    function updateSelection(targetPoint) {
        selectionTo = targetPoint
    }

    function endSelection() {
        selectionFinished(selectionOverlay.minPoint, selectionOverlay.maxPoint)
        selectionActive = false
        selectionFrom = Qt.point(0, 0)
        selectionTo = Qt.point(0, 0)
    }

    function resetSelection() {
        contentView.lastSelectedNode = null
        if (selectionList.length !== 0) {
            for (var i = 0; i < selectionList.length; ++i)
                selectionList[i].isSelected = false
            selectionCount = 0
            selectionList = []
            selectionListModified()
        }
    }

    function processNodeDrop(validDrag, node) {
        if (validDrag) {
            var lastParent = treeSurface.dragTarget.parentNode
            if (node.moveToChildren(treeSurface.dragTarget))
                actionsManager.push(actionsManager.makeActionMoveNode(treeSurface.dragTarget, lastParent, node))
        } else {
            if (node.swapNodes(treeSurface.dragTarget))
                actionsManager.push(actionsManager.makeActionSwapNode(treeSurface.dragTarget, node))
        }
    }

    function addNodeToSelection(nodeDelegate) {
        selectionList.push(nodeDelegate)
        ++selectionCount
        if (contentView.lastSelectedNode == null) {
            contentView.lastSelectedNode = nodeDelegate
        } else {
            contentView.lastSelectedNode = nodeDelegate
        }
        selectionListModified()
    }

    function removeNodeFromSelection(nodeDelegate, index) {
        treeSurface.selectionList.splice(index, 1)
        --treeSurface.selectionCount
        if (contentView.lastSelectedNode == nodeDelegate)
            contentView.lastSelectedNode = null
        selectionListModified()
    }

    function makeNodeSelectionList() {
        var nodes = []
        for (var i = 0; i < selectionList.length; ++i)
            nodes.push(selectionList[i].node)
        return nodes
    }

    property real instanceDefaultWidth: 150
    property real instanceDefaultHeight: 150
    readonly property real instancePadding: instanceDefaultWidth / 2
    property bool dragActive: false
    property point dragPoint: Qt.point(0, 0)
    property NodeModel dragTarget: null
    property string dragTargetPlugin: ""
    property bool selectionActive: false
    property point selectionFrom: Qt.point(0, 0)
    property point selectionTo: Qt.point(0, 0)

    // List of selected TreeNodeDelegate
    property var selectionList: []
    property int selectionCount: 0
    property NodeModel last: null

    signal targetDropped
    signal targetPluginDropped
    signal selectionFinished(point from, point to)
    signal selectionListModified

    id: treeSurface
    width: Math.max(masterNodeDelegate.width, parent.width)
    height: Math.max(masterNodeDelegate.height, parent.height)

    TreeNodeDelegate {
        id: masterNodeDelegate
        node: app.project.master
        anchors.centerIn: parent
    }

    Rectangle {
        readonly property point minPoint: {
            return Qt.point(
                Math.min(treeSurface.selectionFrom.x, treeSurface.selectionTo.x),
                Math.min(treeSurface.selectionFrom.y, treeSurface.selectionTo.y)
            )
        }
        readonly property point maxPoint: {
            return Qt.point(
                Math.max(treeSurface.selectionFrom.x, treeSurface.selectionTo.x),
                Math.max(treeSurface.selectionFrom.y, treeSurface.selectionTo.y)
            )
        }

        id: selectionOverlay
        visible: selectionActive
        x: minPoint.x
        y: minPoint.y
        width: maxPoint.x - minPoint.x
        height: maxPoint.y - minPoint.y
        color: "grey"
        opacity: 0.5
        border.color: "white"
        border.width: 1
    }
}
