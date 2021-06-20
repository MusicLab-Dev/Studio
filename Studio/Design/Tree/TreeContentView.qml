import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

Item {
    // Horizontal scroll (xOffset && xOffsetMin is always zero or less)
    property real xOffset: 0
    property real xOffsetMin: Math.min(width - treeSurface.width, 0)
    readonly property real xOffsetWidth: -xOffsetMin
    readonly property real xScrollIndicatorSize: xOffsetWidth ? 1 / ((xOffsetWidth + width) / width) : 1
    readonly property real xScrollIndicatorPos: (1 - xScrollIndicatorSize) * (xOffsetMin ? xOffset / xOffsetMin : 0)

    // Vertical scroll (yOffset && yOffsetMin is always zero or less)
    property real yOffset: 0
    property real yOffsetMin: Math.min(height - treeSurface.height, 0)
    readonly property real yOffsetWidth: -yOffsetMin
    readonly property real yScrollIndicatorSize: yOffsetWidth ? 1 / ((yOffsetWidth + height) / height) : 1
    readonly property real yScrollIndicatorPos: (1 - yScrollIndicatorSize) * (yOffsetMin ? yOffset / yOffsetMin : 0)

    // Horizontal zoom
    property real xZoom: 0.5
    property real xZoomMin: 50
    property real xZoomMax: 300
    readonly property real xZoomWidth: xZoomMax - xZoomMin

    // Vertical zoom
    property real yZoom: xZoom
    property real yZoomMin: xZoomMin * 0.75
    property real yZoomMax: xZoomMax * 0.75
    readonly property real yZoomWidth: yZoomMax - yZoomMin

    // Scroll gesture
    readonly property real wheelsPerXScrollPage: 1
    readonly property real wheelsPerYScrollPage: 1
    readonly property real xScrollFactor: width / (wheelsPerXScrollPage * 360 * 8)
    readonly property real yScrollFactor: height / (wheelsPerYScrollPage * 360 * 8)

    // Zoom gesture
    readonly property real wheelsPerXZoomRange: 5
    readonly property real wheelsPerYZoomRange: 5
    readonly property real xZoomFactor: 1 / (wheelsPerXZoomRange * 360 * 8)
    readonly property real yZoomFactor: 1 / (wheelsPerYZoomRange * 360 * 8)


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
        function applyZoom(zoom) {
            var oldXPos = contentView.xOffset + treeSurface.width + mouseX
            var oldYPos = contentView.yOffset + treeSurface.height + mouseY
            console.log("Old", treeSurface.width, treeSurface.height)
            contentView.xZoom = Math.min(Math.max(contentView.xZoom + contentView.xZoomFactor * zoom, 0), 1)
            treeSurface.invalidate()
            console.log("New", treeSurface.width, treeSurface.height)
            var newXPos = contentView.xOffset + treeSurface.width + mouseX
            var newYPos = contentView.yOffset + treeSurface.height + mouseY
            // console.log("Zoom", oldXPos, oldYPos, newXPos, newYPos, "-", newXPos - oldXPos, newYPos - oldYPos)
            contentView.xOffset = Math.min(Math.max(contentView.xOffset + newXPos - oldXPos, contentView.xOffsetMin), 0)
            contentView.yOffset = Math.min(Math.max(contentView.yOffset + newYPos - oldYPos, contentView.yOffsetMin), 0)
        }

        id: gestureArea
        anchors.fill: parent

        onXScrolled: {
            contentView.xOffset = Math.min(Math.max(contentView.xOffset + contentView.xScrollFactor * scroll, contentView.xOffsetMin), 0)
        }

        onYScrolled: {
            contentView.yOffset = Math.min(Math.max(contentView.yOffset + contentView.yScrollFactor * scroll, contentView.yOffsetMin), 0)
        }

        onXZoomed: {
            applyZoom(zoom)
        }

        onYZoomed: {
            applyZoom(zoom)
        }
    }

    TreeSurface {
        id: treeSurface
        x: contentView.xOffset
        y: contentView.yOffset
        instanceDefaultWidth: contentView.xZoomMin + contentView.xZoom * contentView.xZoomWidth
        instanceDefaultHeight: contentView.yZoomMin + contentView.yZoom * contentView.yZoomWidth

        onWidthChanged: {
            console.log("Width changed", width)
        }
    }

    ScrollBar {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: size !== 1
        orientation: Qt.Vertical
        size: contentView.yScrollIndicatorSize
        position: contentView.yScrollIndicatorPos
        policy: ScrollBar.AlwaysOn

        onPositionChanged: {
            if (Math.abs(position - contentView.yScrollIndicatorPos) > Number.EPSILON)
                contentView.yOffset = contentView.yOffsetMin * position / (1 - size)
        }
    }

    ScrollBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: size !== 1
        orientation: Qt.Horizontal
        size: contentView.xScrollIndicatorSize
        position: contentView.xScrollIndicatorPos
        policy: ScrollBar.AlwaysOn

        onPositionChanged: {
            if (Math.abs(position - contentView.xScrollIndicatorPos) > Number.EPSILON)
                contentView.xOffset = contentView.xOffsetMin * position / (1 - size)
        }
    }
}