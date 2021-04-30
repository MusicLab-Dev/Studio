import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0

Item {
    // Content data placeholder
    default property alias placeholder: placeholder.data

    // Rows dimensions
    property real rowHeight: yZoom * yZoomWidth + yZoomMin
    property real rowHeaderWidth: width * 0.2
    readonly property real rowDataWidth: width - rowHeaderWidth

    // Columns dimensions
    property int barsPerRow: xZoom * xZoomWidth + xZoomMin
    property int beatsPerBar: 4

    // Horizontal scroll (xOffset && xOffsetMin is always zero or less)
    property real xOffset: 0
    property real xOffsetMin: 0

    // Vertical scroll (yOffset && yOffsetMin is always zero or less)
    property real yOffset: 0
    property real yOffsetMin: 0
    readonly property real yOffsetWidth: -yOffsetMin
    readonly property real yScrollIndicatorSize: yOffsetWidth ? 1 / (yOffsetWidth / width) : 1
    readonly property real yScrollIndicatorPos: (1 - yScrollIndicatorSize) * (yOffsetMin ? yOffset / yOffsetMin : 0)

    // Horizontal zoom
    property real xZoom: 0.05
    property real xZoomMin: 1
    property real xZoomMax: 100
    readonly property real xZoomWidth: xZoomMax - xZoomMin

    // Vertical zoom
    property real yZoom: 0.1
    property real yZoomMin: 30
    property real yZoomMax: 300
    readonly property real yZoomWidth: yZoomMax - yZoomMin

    // Scroll gesture
    readonly property real wheelsPerXScrollPage: 1
    readonly property real wheelsPerYScrollPage: 1
    readonly property real xScrollFactor: width / (wheelsPerXScrollPage * 360 * 8)
    readonly property real yScrollFactor: height / (wheelsPerYScrollPage * 360 * 8)

    // Zoom gesture
    readonly property real wheelsPerXZoomRange: 2
    readonly property real wheelsPerYZoomRange: 2
    readonly property real xZoomFactor: 1 / (wheelsPerXZoomRange * 360 * 8)
    readonly property real yZoomFactor: 1 / (wheelsPerYZoomRange * 360 * 8)

    // Global access data
    property alias surfaceContentGrid: surfaceContentGrid
    property alias placementRectangle: placementRectangle

    // Placement ratios
    property real placementKeyCount: 0
    readonly property real beatPrecision: 128
    readonly property real pixelsPerBeat: surfaceContentGrid.cellWidth / surfaceContentGrid.barsPerCell / beatsPerBar
    readonly property real pixelsPerBeatPrecision: pixelsPerBeat / beatPrecision

    // Placement states in beat precision (128 unit = 1 beat)
    readonly property real placementBeatPrecisionWidth: placementBeatPrecisionTo - placementBeatPrecisionFrom
    property real placementBeatPrecisionDefaultWidth: placementBeatPrecisionScale !== 0 ? placementBeatPrecisionScale : beatPrecision
    property real placementBeatPrecisionLastWidth: 0
    property real placementKeyOffset: 0 // Only used for notes
    property real placementKey: -1 // Only used for notes
    property real placementBeatPrecisionFrom: 0
    property real placementBeatPrecisionTo: 0
    property real placementBeatPrecisionMouseOffset: 0

    // Placement states in pixel precision
    readonly property real placementPixelFrom: xOffset + pixelsPerBeatPrecision * placementBeatPrecisionFrom
    readonly property real placementPixelTo: xOffset + pixelsPerBeatPrecision * placementBeatPrecisionTo
    readonly property real placementPixelWidth: pixelsPerBeatPrecision * placementBeatPrecisionWidth
    property real placementPixelY: {
        return placementKey === -1 ? 0 : (placementKeyCount - 1 - (placementKey - placementKeyOffset)) * rowHeight
    }
    readonly property real placementResizeMaxPixelThreshold: 20
    property real placementResizeRatioThreshold: 0.25

    // Scale used to perfectly fit placements in beat
    property int placementBeatPrecisionScale: AudioAPI.beatPrecision

    // Timeline bar
    property real timelineBeatPrecision: 0
    property real audioProcessBeatPrecision: 0

    // Timeline
    readonly property int timelineHeight: 25
    property bool hasLoop: false
    property int loopFrom: 0
    property int loopTo: 0

    signal timelineBeginMove(var target)
    signal timelineMove(var target)
    signal timelineEndMove()

    function disableLoopRange() {
        hasLoop = false
        loopFrom = 0
        loopTo = 0
        app.scheduler.disableLoopRange()
    }

    id: contentView

    onXOffsetMinChanged: {
        if (xOffset < xOffsetMin)
            xOffset = xOffsetMin
    }

    onYOffsetMinChanged: {
        if (yOffset < yOffsetMin)
            yOffset = yOffsetMin
    }

    // Content background
    Rectangle {
        id: contentDataBackground
        x: contentView.rowHeaderWidth
        y: contentViewTimeline.height
        width: contentView.rowDataWidth
        height: contentView.height - contentViewTimeline.height
        color: themeManager.backgroundColor
    }

    // Handle all mouse / touch gestures
    GestureArea {
        id: gestureArea
        anchors.fill: parent

        onScrolled: {
            xOffset = Math.min(Math.max(xOffset + xScrollFactor * scrollX, xOffsetMin), 0)
            yOffset = Math.min(Math.max(yOffset + yScrollFactor * scrollY, yOffsetMin), 0)
        }

        onZoomed: {
            xZoom = Math.min(Math.max(xZoom + xZoomFactor * zoomX, 0), 1)
            yZoom = Math.min(Math.max(yZoom + yZoomFactor * zoomY, 0), 1)
        }
    }

    ContentViewTimeline {
        id: contentViewTimeline
        height: timelineHeight
        width: contentView.width
        z: 1
    }

    Item {
        width: parent.width
        height: contentView.height - contentViewTimeline.height
        y: contentViewTimeline.height

        // Content view data
        Item {
            id: placeholder
            anchors.fill: parent
        }

        // Data grid overlay
        SurfaceContentGrid {
            id: surfaceContentGrid
            x: contentView.rowHeaderWidth
            width: contentView.rowDataWidth
            height: parent.height
            xOffset: contentView.xOffset
            yOffset: contentView.yOffset
            rowHeight: contentView.rowHeight
            barsPerRow: contentView.barsPerRow
            z: 0

            Rectangle {
                width: 4
                height: surfaceContentGrid.height
                x: xOffset + audioProcessBeatPrecision * pixelsPerBeatPrecision
                color: "red"
                opacity: 0.5
            }

            ScrollBar {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                active: size !== 1
                visible: true
                orientation: Qt.Vertical
                size: yScrollIndicatorSize
                position: yScrollIndicatorPos
                policy: ScrollBar.AlwaysOn

                onPositionChanged: {
                    // yOffset = yOffsetMin * position / size
                }
            }
        }
    }

    ContentViewTimelineBar {
        id: timeline
        visible: x >= rowHeaderWidth
        width: 20
        height: surfaceContentGrid.height
        x: rowHeaderWidth + xOffset + timelineBeatPrecision * pixelsPerBeatPrecision - width / 2
    }

    Rectangle {
        property color targetColor: "white"

        function attach(newParent, newColor) {
            parent = newParent
            targetColor = newColor
            visible = true
        }

        function detach(newParent) {
            parent = contentView
            visible = false
        }

        id: placementRectangle
        x: contentView.placementPixelFrom
        y: contentView.placementPixelY
        width: contentView.placementPixelWidth
        height: contentView.rowHeight
        visible: false
        color: Qt.lighter(targetColor, 1.3)
    }
}
