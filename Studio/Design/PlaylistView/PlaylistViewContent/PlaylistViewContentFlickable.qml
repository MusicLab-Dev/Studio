import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"
import "../../Common"

Item {
    id: playlistViewContentFlickable
    property int rowHeight: 30

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true
        contentHeight: height
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: DefaultScrollBar {
            policy: ScrollBar.AlwaysOn
        }

        PlaylistViewContentHeader {
            id: playlistViewContentHeader
            height: parent.height
            width: parent.width * 0.1
        }
    }

    PlaylistViewContentGrid {
        id: playlistViewContentGrid
        anchors.fill: parent
        anchors.leftMargin: playlistViewContentHeader.width
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
            zoomXFactor = Math.min(Math.max(zoomXFactor + zoomX / 10, 0), 1)
            zoomYFactor = Math.min(Math.max(zoomYFactor + zoomY / 120, 0), 1)
        }
    }
}
