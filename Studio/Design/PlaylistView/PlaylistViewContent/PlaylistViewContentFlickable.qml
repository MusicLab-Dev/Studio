import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"
import "../../Common"

import "./PlaylistViewContentNodeView"

Item {
    property alias rowHeight: surfaceContentGrid.rowHeight
    property alias totalHeight: nodeView.totalHeight

    id: playlistViewContentFlickable

    Rectangle {
        x: nodeView.headerWidth
        width: parent.width - nodeView.headerWidth
        height: parent.height
        color: themeManager.backgroundColor
    }

    PlaylistViewContentNodeView {
        id: nodeView
        anchors.fill: parent
    }

    SurfaceContentGrid {
        id: surfaceContentGrid
        contentYOffset: nodeView.contentY
        anchors.fill: parent
        anchors.leftMargin: nodeView.headerWidth
    }

    PlaylistViewContentNodeViewPluginAddMenu {
        id: playlistViewContentNodeViewPluginAddMenu
    }

    PlaylistViewContentNodeViewPluginSettingsMenu {
        id: playlistViewContentNodeViewPluginSettingsMenu
    }

    GestureArea {
        readonly property int zoomXFrom: 20
        readonly property int zoomXTo: 100
        readonly property int zoomXRange: zoomXTo - zoomXFrom
        property real zoomXFactor: 0.5

        readonly property int zoomYFrom: 20
        readonly property int zoomYTo: 100
        readonly property int zoomYRange: zoomYTo - zoomYFrom
        property real zoomYFactor: 0.5

        readonly property int scrollXRange: nodeView.maxContentX - nodeView.minContentX
        property real scrollXFactor: 0

        readonly property int scrollYRange: nodeView.maxContentY - nodeView.minContentY
        property real scrollYFactor: 0

        id: gestureArea
        anchors.fill: parent
        focus: true

        onZoomXFactorChanged: {
            surfaceContentGrid.barsPerLine = zoomXRange * zoomXFactor + zoomXFrom
        }

        onZoomYFactorChanged: {
            rowHeight = zoomYRange * zoomYFactor + zoomYFrom
        }

        onScrollXFactorChanged: {
            nodeView.contentX = scrollXRange * scrollXFactor + nodeView.minContentX
        }

        onScrollYFactorChanged: {
            nodeView.contentY = scrollYRange * scrollYFactor + nodeView.minContentY
        }

        onZoomed: {
            zoomXFactor = Math.min(Math.max(zoomXFactor + zoomX / 360, 0), 1)
            zoomYFactor = Math.min(Math.max(zoomYFactor + zoomY / 360, 0), 1)
        }

        onScrolled: {
            scrollXFactor = Math.min(Math.max(scrollXFactor + scrollX / 360, 0), 1)
            scrollYFactor = Math.min(Math.max(scrollYFactor + scrollY / 360, 0), 1)
        }
    }
}
