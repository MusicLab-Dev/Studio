import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0
import PartitionPreview 1.0

Item {
    enum EditMode {
        Regular,
        Brush,
        Select,
        Cut
    }

    // Content data placeholder
    default property alias placeholder: placeholder.data

    // Inputs
    property Player player

    // Display inputs
    property alias enableRows: surfaceContentGrid.enableRows

    // Rows dimensions
    property real rowHeight: yZoom * yZoomWidth + yZoomMin
    property real rowHeaderWidth: width * 0.2
    readonly property real rowDataWidth: width - rowHeaderWidth

    // Columns dimensions
    readonly property int beatsPerRow: xZoom * xZoomWidth + xZoomMin
    property int beatsPerBar: 4

    // Horizontal scroll (xOffset && xOffsetMin is always zero or less)
    property real xOffset: 0
    property real xOffsetMin: 0
    readonly property real xOffsetWidth: -xOffsetMin
    readonly property real xScrollIndicatorSize: xOffsetWidth ? 1 / ((xOffsetWidth + width) / width) : 1
    readonly property real xScrollIndicatorPos: (1 - xScrollIndicatorSize) * (xOffsetMin ? xOffset / xOffsetMin : 0)

    // Vertical scroll (yOffset && yOffsetMin is always zero or less)
    property real yOffset: 0
    property real yOffsetMin: 0
    readonly property real yOffsetWidth: -yOffsetMin
    readonly property real yScrollIndicatorSize: yOffsetWidth ? 1 / (yOffsetWidth / height) : 1
    readonly property real yScrollIndicatorPos: (1 - yScrollIndicatorSize) * (yOffsetMin ? yOffset / yOffsetMin : 0)

    // Scroll gesture
    readonly property real wheelsPerXScrollPage: 1
    readonly property real wheelsPerYScrollPage: 1
    readonly property real xScrollFactor: width / (wheelsPerXScrollPage * 360 * 8)
    readonly property real yScrollFactor: height / (wheelsPerYScrollPage * 360 * 8)

    // Horizontal zoom
    property real xZoom: 0.05
    property real xZoomMin: beatsPerBar + 1
    property real xZoomMax: 100 * beatsPerBar
    readonly property real xZoomWidth: xZoomMax - xZoomMin

    // Vertical zoom
    property real yZoom: 0.05
    property real yZoomMin: 70
    property real yZoomMax: 200
    readonly property real yZoomWidth: yZoomMax - yZoomMin

    // Zoom gesture
    readonly property real wheelsPerXZoomRange: 5
    readonly property real wheelsPerYZoomRange: 1
    readonly property real xZoomFactor: 1 / (wheelsPerXZoomRange * 360 * 8)
    readonly property real yZoomFactor: 1 / (wheelsPerYZoomRange * 360 * 8)

    // Global access data
    property alias surfaceContentGrid: surfaceContentGrid
    property alias gestureArea: gestureArea
    property alias timelineBar: timelineBar

    // Placement ratios
    property real placementKeyCount: 0
    readonly property real beatPrecision: 128
    readonly property real pixelsPerBeat: surfaceContentGrid.width / beatsPerRow
    readonly property real pixelsPerBeatPrecision: pixelsPerBeat / beatPrecision

    // Placement states in beat precision (128 unit = 1 beat)
    readonly property real placementBeatPrecisionWidth: placementBeatPrecisionTo - placementBeatPrecisionFrom
    property real placementBeatPrecisionDefaultWidth: placementBeatPrecisionScale !== 0 ? placementBeatPrecisionScale : beatPrecision
    property real placementBeatPrecisionLastWidth: 0
    property real placementBeatPrecisionBrushStep: 0
    property real placementKeyOffset: 0 // Only used for notes
    property real placementKey: -1 // Only used for notes
    property real placementBeatPrecisionFrom: 0
    property real placementBeatPrecisionTo: 0

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

    // Timeline
    readonly property int timelineHeight: 25
    property alias timelineCursor: contentViewTimeline.timelineCursor

    // Edit tools
    property int editMode: ContentView.EditMode.Regular

    id: contentView

    onXOffsetMinChanged: {
        if (xOffset < xOffsetMin)
            xOffset = xOffsetMin
    }

    onYOffsetMinChanged: {
        if (yOffset < yOffsetMin)
            yOffset = yOffsetMin
    }

    // Handle all mouse / touch gestures
    GestureArea {
        id: gestureArea
        anchors.fill: parent

        onOffsetScroll: {
            xOffset = Math.min(Math.max(xOffset + xOffset, xOffsetMin), 0)
            yOffset = Math.min(Math.max(yOffset + yOffset, yOffsetMin), 0)
        }

        onXScrolled: {
            xOffset = Math.min(Math.max(xOffset + xScrollFactor * scroll, xOffsetMin), 0)
        }

        onYScrolled: {
            yOffset = Math.min(Math.max(yOffset + yScrollFactor * scroll, yOffsetMin), 0)
        }

        onXZoomed: {
            var realPos = xPos > rowHeaderWidth ? xPos - rowHeaderWidth : 0
            var posRatio = realPos / rowDataWidth
            var targetBeat = (-xOffset + realPos) / pixelsPerBeatPrecision
            xZoom = Math.min(Math.max(xZoom + xZoomFactor * zoom, 0), 1)
            var offset = -targetBeat * pixelsPerBeatPrecision + rowDataWidth * posRatio
            if (offset > 0)
                offset = 0
            else if (offset < xOffsetMin)
                offset = xOffsetMin
            xOffset = offset
        }

        onYZoomed: {
            var realPos = yPos > timelineHeight ? yPos - timelineHeight : 0
            var posRatio = realPos / surfaceContentGrid.height
            var targetRow = (-yOffset + realPos) / rowHeight
            yZoom = Math.min(Math.max(yZoom + yZoomFactor * zoom, 0), 1)
            var offset = -targetRow * rowHeight + surfaceContentGrid.height * posRatio
            if (offset > 0)
                offset = 0
            else if (offset < yOffsetMin)
                offset = yOffsetMin
            yOffset = offset
        }
    }

    ContentViewTimeline {
        id: contentViewTimeline
        player: contentView.player
        height: timelineHeight
        width: contentView.width
        z: 1
    }

    Item {
        width: parent.width
        height: contentView.height - contentViewTimeline.height
        y: contentViewTimeline.height

        // Data grid overlay
        SurfaceContentGrid {
            id: surfaceContentGrid
            x: contentView.rowHeaderWidth
            width: contentView.rowDataWidth
            height: parent.height
            xOffset: contentView.xOffset
            yOffset: contentView.yOffset
            rowHeight: contentView.rowHeight
            beatsPerRow: contentView.beatsPerRow
            z: 0
        }

        // Content view data
        Item {
            id: placeholder
            anchors.fill: parent
        }

        Item {
            anchors.fill: surfaceContentGrid

            Rectangle {
                visible: player.hasLoop
                color: "grey"
                opacity: 0.6
                anchors.left: parent.left
                anchors.right: loopFromBar.left
                height: contentView.height
            }

            Rectangle {
                visible: player.hasLoop
                color: "grey"
                opacity: 0.6
                anchors.left: loopToBar.right
                anchors.right: parent.right
                height: contentView.height
            }

            Rectangle {
                id: loopFromBar
                x: contentViewTimeline.loopFromIndicatorX
                width: 1
                height: contentView.height
                color: themeManager.accentColor
                visible: player.hasLoop
            }

            Rectangle {
                id: loopToBar
                x: contentViewTimeline.loopToIndicatorX
                width: 1
                height: contentView.height
                color: themeManager.accentColor
                visible: player.hasLoop
            }

            ScrollBar {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                visible: size !== 1
                orientation: Qt.Vertical
                size: yScrollIndicatorSize
                position: yScrollIndicatorPos
                policy: ScrollBar.AlwaysOn

                onPositionChanged: {
                    if (Math.abs(position - yScrollIndicatorPos) > Number.EPSILON)
                        yOffset = yOffsetMin * position / (1 - size)
                }
            }

            ScrollBar {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                visible: size !== 1
                orientation: Qt.Horizontal
                size: xScrollIndicatorSize
                position: xScrollIndicatorPos
                policy: ScrollBar.AlwaysOn

                onPositionChanged: {
                    if (Math.abs(position - xScrollIndicatorPos) > Number.EPSILON)
                        xOffset = xOffsetMin * position / (1 - size)
                }
            }
        }
    }

    ContentViewTimelineBar {
        id: timelineBar
        visible: x >= rowHeaderWidth
        color: "#00ECBA"
        width: 1
        height: parent.height - timelineCursor.height
        x: rowHeaderWidth + xOffset + player.currentPlaybackBeat * contentView.pixelsPerBeatPrecision
        y: timelineCursor.height
        z: contentViewTimeline.z + 1
    }

    ContentViewTimelineBar {
        id: playFromBar
        visible: x >= rowHeaderWidth
        color: themeManager.accentColor
        opacity: 0.5
        width: 1
        height: parent.height - timelineCursor.height
        x: rowHeaderWidth + xOffset + player.playFrom * contentView.pixelsPerBeatPrecision
        y: timelineCursor.height
        z: contentViewTimeline.z + 1
    }
}
