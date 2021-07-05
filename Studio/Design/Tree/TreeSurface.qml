import QtQuick 2.15

import NodeModel 1.0

Item {
    function startDrag(targetNode, targetPoint) {
        console.log("Drag started", targetNode.name, targetPoint)
        dragTarget = targetNode
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
        dragPoint = Qt.point(0, 0)
    }

    signal targetDropped

    property real instanceDefaultWidth: 150
    property real instanceDefaultHeight: 100
    readonly property real instancePadding: instanceDefaultWidth / 2
    property NodeModel selectedNode: null
    property bool dragActive: false
    property point dragPoint: Qt.point(0, 0)
    property NodeModel dragTarget: null

    id: treeSurface
    width: masterNodeDelegate.width
    height: masterNodeDelegate.height

    TreeNodeDelegate {
        id: masterNodeDelegate
        node: app.project.master
    }
}