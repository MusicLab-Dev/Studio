import QtQuick 2.15

import NodeModel 1.0

Item {
    property real instanceDefaultWidth: 100
    property real instanceDefaultHeight: 75
    readonly property real instanceExpandedWidth: instanceDefaultWidth * 2
    readonly property real instanceExpandedHeight: instanceDefaultHeight * 2
    readonly property real instancePadding: instanceDefaultWidth / 2
    property NodeModel selectedNode: null

    id: treeSurface
    width: masterNodeDelegate.width
    height: masterNodeDelegate.height

    TreeNodeDelegate {
        id: masterNodeDelegate
        node: app.project.master
    }
}