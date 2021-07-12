import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Common"

MouseArea {
    property alias treeSurface: treeSurface

    function incrementXOffset(offset) {
        contentView.xOffset = Math.min(Math.max(contentView.xOffset + offset, contentView.xOffsetMin), contentView.xOffsetMax)
    }

    function incrementYOffset(offset) {
        contentView.yOffset = Math.min(Math.max(contentView.yOffset + offset, contentView.yOffsetMin), contentView.yOffsetMax)
    }

    // Horizontal scroll
    property real xOffset: 0
    readonly property real xOffsetMin: Math.min(-treeSurface.scaledWidth / 2, -width / 2)
    readonly property real xOffsetMax: -xOffsetMin
    readonly property real xOffsetWidth: xOffsetMax * 2
    readonly property real xScrollIndicatorSize: xOffsetWidth ? 1 / ((xOffsetWidth + width) / width) : 1
    readonly property real xScrollIndicatorPos: (1 - xScrollIndicatorSize) *  (1 - ((xOffset - xOffsetMin) / xOffsetWidth))

    // Vertical scroll
    property real yOffset: 0
    readonly property real yOffsetMin: Math.min(-treeSurface.scaledHeight / 2, -height / 2)
    readonly property real yOffsetMax: -yOffsetMin
    readonly property real yOffsetWidth: yOffsetMax * 2
    readonly property real yScrollIndicatorSize: yOffsetWidth ? 1 / ((yOffsetWidth + height) / height) : 1
    readonly property real yScrollIndicatorPos: (1 - yScrollIndicatorSize) * (1 - ((yOffset - yOffsetMin) / yOffsetWidth))

    // Scroll gesture
    readonly property real wheelsPerXScrollPage: 3
    readonly property real wheelsPerYScrollPage: 3
    readonly property real xScrollFactor: width / (wheelsPerXScrollPage * 360 * 8)
    readonly property real yScrollFactor: height / (wheelsPerYScrollPage * 360 * 8)

    // Zoom
    property real zoom: 0.25
    readonly property real zoomMin: 0.4
    readonly property real zoomMax: 3
    readonly property real zoomWidth: zoomMax - zoomMin

    // Zoom gesture
    readonly property real wheelsPerZoomRange: 3
    readonly property real zoomFactor: 1 / (wheelsPerZoomRange * 360 * 8)

    id: contentView

    onClicked: treeSurface.selectedNode = null

    onXOffsetMinChanged: {
        if (xOffset < xOffsetMin)
            xOffset = xOffsetMin
    }

    onXOffsetMaxChanged: {
        if (xOffset >= xOffsetMax)
            xOffset = xOffsetMax
    }

    onYOffsetMinChanged: {
        if (yOffset < yOffsetMin)
            yOffset = yOffsetMin
    }

    onYOffsetMaxChanged: {
        if (yOffset >= yOffsetMax)
            yOffset = yOffsetMax
    }

    // Handle all mouse / touch gestures
    GestureArea {
        id: gestureArea
        anchors.fill: parent

        onOffsetScroll: {
            contentView.incrementXOffset(xOffset)
            contentView.incrementYOffset(yOffset)
        }

        onXScrolled: contentView.incrementXOffset(contentView.xScrollFactor * scroll)
        onYScrolled: contentView.incrementYOffset(contentView.yScrollFactor * scroll)

        onXZoomed: {
            var oldWidth = treeSurface.scaledWidth
            var oldHeight = treeSurface.scaledHeight
            var oldXRatio = Math.min(Math.max((xPos - treeSurface.x) / oldWidth, 0), 1) - 0.5
            var oldYRatio = Math.min(Math.max((yPos - treeSurface.y) / oldHeight, 0), 1) - 0.5
            contentView.zoom = Math.min(Math.max(contentView.zoom + contentView.zoomFactor * zoom, 0), 1)
            contentView.incrementXOffset(-oldXRatio * (treeSurface.scaledWidth - oldWidth))
            contentView.incrementYOffset(-oldYRatio * (treeSurface.scaledHeight - oldHeight))
        }
    }

    TreeSurface {
        readonly property real scaledWidth: width * scale
        readonly property real scaledHeight: height * scale

        id: treeSurface
        x: parent.width / 2 - scaledWidth / 2 + contentView.xOffset
        y: parent.height / 2 - scaledHeight / 2 + contentView.yOffset
        transformOrigin: Item.TopLeft
        scale: contentView.zoomMin + contentView.zoom * contentView.zoomWidth
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
                contentView.yOffset = contentView.yOffsetMin + contentView.yOffsetWidth * position / (1 - size)
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
                contentView.xOffset = contentView.xOffsetMin + contentView.xOffsetWidth * position / (1 - size)
        }
    }

    TreeComponentsPanel {
        anchors.fill: parent
    }
}
