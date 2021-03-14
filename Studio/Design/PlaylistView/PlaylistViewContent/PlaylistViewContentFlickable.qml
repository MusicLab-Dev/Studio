import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"
import "../../Common"

Item {
    property alias rowHeight: playlistViewContentNodeView.rowHeight
    // property alias totalHeight: playlistViewContentHeader.totalGridHeight
    property alias totalHeight: playlistViewContentNodeView.totalHeight

    id: playlistViewContentFlickable

    Rectangle {
        x: playlistViewContentNodeView.headerWidth
        width: parent.width - playlistViewContentNodeView.headerWidth
        height: parent.height
        color: "#4A8693"
    }

    PlaylistViewContentNodeView {
        id: playlistViewContentNodeView
        anchors.fill: parent
    }

    // Flickable {
    //     id: flickable
    //     anchors.fill: parent
    //     clip: true
    //     contentHeight: totalHeight
    //     boundsBehavior: Flickable.StopAtBounds

    //     ScrollBar.vertical: DefaultScrollBar {
    //         policy: ScrollBar.AlwaysOn
    //     }

    //     PlaylistViewContentHeader {
    //         id: playlistViewContentHeader
    //         height: parent.height
    //         width: parent.width * 0.2
    //     }
    // }

    PlaylistViewContentGrid {
        id: playlistViewContentGrid
        anchors.fill: parent
        anchors.leftMargin: playlistViewContentNodeView.headerWidth
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

        id: gestureArea
        anchors.fill: parent
        focus: true

        onZoomXFactorChanged: {
            playlistViewContentGrid.barsPerLine = zoomXRange * zoomXFactor + zoomXFrom
        }

        onZoomYFactorChanged: {
            rowHeight = zoomYRange * zoomYFactor + zoomYFrom
        }

        onZoomed: {
            zoomXFactor = Math.min(Math.max(zoomXFactor + zoomX / 500, 0), 1)
            zoomYFactor = Math.min(Math.max(zoomYFactor + zoomY / 500, 0), 1)
        }
    }
}
