import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"
import "../../Common"

Item {
    property alias totalHeight: piano.totalGridHeight
    property alias rowHeight: surfaceContentGrid.rowHeight

    Rectangle {
        x: piano.keyWidth
        width: parent.width - piano.keyWidth
        height: parent.height
        color: themeManager.backgroundColor
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true
        contentHeight: totalHeight
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: DefaultScrollBar {
            policy: ScrollBar.AlwaysOn
        }

        SequencerViewContentPiano {
            id: piano
        }
    }

    SurfaceContentGrid {
        id: surfaceContentGrid
        contentYOffset: flickable.contentY
        anchors.fill: parent
        anchors.leftMargin: piano.keyWidth
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
            surfaceContentGrid.barsPerLine = zoomXRange * zoomXFactor + zoomXFrom
        }

        onZoomYFactorChanged: {
            surfaceContentGrid.rowHeight = zoomYRange * zoomYFactor + zoomYFrom
        }

        onZoomed: {
            zoomXFactor = Math.min(Math.max(zoomXFactor + zoomX / 500, 0), 1)
            zoomYFactor = Math.min(Math.max(zoomYFactor + zoomY / 500, 0), 1)
        }
    }
}
