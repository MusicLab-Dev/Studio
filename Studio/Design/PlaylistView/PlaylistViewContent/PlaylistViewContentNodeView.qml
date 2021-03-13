import QtQuick 2.15
import QtQuick.Controls 2.15

import NodeModel 1.0

Flickable {
    property real rowHeight: 150
    property real emptyRowHeight: 50

    property real headerWidth: width * 0.25
    property real headerPluginWidth: headerWidth / 2
    property real headerDataWidth: headerWidth / 2
    property real dataWidth: width - headerWidth

    property real linkWidth: 10
    property real linkSpacing: 10

    property real totalHeight: master.height

    id: nodeView
    clip: true
    contentHeight: totalHeight
    boundsBehavior: Flickable.StopAtBounds

    PlaylistViewContentNodeDelegate {
        id: master
        node: app.project.master
        recursionIndex: 0
    }
}