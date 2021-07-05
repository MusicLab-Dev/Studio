import QtQuick 2.15

import AudioAPI 1.0

MouseArea {
    function getPointY(value) {
        return height * (1 - ((value - minValue) / rangeValue))
    }

    function addPoint() {
        var targetBeatPrecision = (mouseX - contentView.xOffset) / contentView.pixelsPerBeatPrecision
        var point = AudioAPI.point(
            targetBeatPrecision,
            Point.CurveType.Linear,
            0,
            (1 - (mouseY / height)) * rangeValue + minValue
        )
        point.value = Math.min(Math.max(point.value, minValue), maxValue)
        automationDelegate.automation.add(point)
        automationCanvas.requestPaint()
    }

    readonly property real minValue: controlMinValue
    readonly property real maxValue: controlMaxValue
    readonly property real rangeValue: controlMaxValue - controlMinValue
    readonly property real stepValue: controlStepValue
    readonly property real currentValue: controlValue
    property bool isRemoving: false
    property int removeFromBeatPrecision: 0
    property int removeToBeatPrecision: 0

    onCurrentValueChanged: automationCanvas.requestPaint()

    id: automationRow
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: {
        if (mouse.button === Qt.RightButton) {
            isRemoving = true
            removeFromBeatPrecision = (contentView.xOffset + mouse.x) / contentView.pixelsPerBeatPrecision
            removeToBeatPrecision = removeFromBeatPrecision
        } else {
            isRemoving = false
            addPoint()
        }
    }

    onPositionChanged: {
        if (isRemoving)
            removeToBeatPrecision = Math.max((contentView.xOffset + mouse.x) / contentView.pixelsPerBeatPrecision, 0)
    }

    onReleased: {
        if (isRemoving) {
            isRemoving = false
            automationDelegate.automation.removeSelection(AudioAPI.beatRange(
                Math.min(removeFromBeatPrecision, removeToBeatPrecision),
                Math.max(removeFromBeatPrecision, removeToBeatPrecision)
            ))
            automationCanvas.requestPaint()
            return
        }
    }

    Canvas {
        id: automationCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var automation = automationDelegate.automation
            var count = automation ? automation.count() : 0
            ctx.lineWidth = 2
            // Check for empty automation
            if (!count) {
                var value = getPointY(currentValue)
                ctx.strokeStyle = "white"
                ctx.beginPath()
                ctx.moveTo(0, value)
                ctx.lineTo(width, value)
                ctx.stroke()
                return
            }
            // Collect points
            var viewBeginBeat = -contentView.xOffset / contentView.pixelsPerBeatPrecision
            var viewEndBeat = viewBeginBeat + width / contentView.pixelsPerBeatPrecision
            var firstPoint = automation.getPoint(0)
            var lastPoint = firstPoint
            var pointList = []
            var i = 1
            for (; i < count; ++i) {
                var point = automation.getPoint(i)
                if (point.beat >= viewBeginBeat)
                    break
                firstPoint = point
            }
            for (; i < count; ++i) {
                lastPoint = automation.getPoint(i)
                if (point.beat > viewEndBeat)
                    break
                pointList.push(lastPoint)
            }

            // Start path rendering
            var rectList = []
            ctx.strokeStyle = nodeDelegate.color
            ctx.beginPath()

            // Draw first line
            var beginX = contentView.xOffset
            var firstX = beginX + firstPoint.beat * contentView.pixelsPerBeatPrecision
            var firstY = getPointY(firstPoint.value)
            ctx.moveTo(beginX, firstY)
            if (firstPoint.beat >= viewBeginBeat) {
                ctx.lineTo(firstX, firstY)
                rectList.push(Qt.point(firstX, firstY))
            }

            // Draw each sub-line
            for (i = 0; i < pointList.length; ++i) {
                var point = pointList[i]
                var pointX = contentView.xOffset + point.beat * contentView.pixelsPerBeatPrecision
                var pointY = getPointY(point.value)
                ctx.lineTo(pointX, pointY)
                rectList.push(Qt.point(pointX, pointY))
            }

            // Draw last line
            if (firstPoint == lastPoint)
                ctx.lineTo(width, firstY)
            else if (lastPoint.beat < viewEndBeat) {
                ctx.stroke()
                ctx.beginPath()
                ctx.strokeStyle = "white"
                var lastValue = getPointY(lastPoint.value)
                ctx.moveTo(contentView.xOffset + lastPoint.beat * contentView.pixelsPerBeatPrecision, lastValue)
                ctx.lineTo(width, lastValue)
            }
            ctx.stroke()

            ctx.fillStyle = nodeDelegate.color
            for (i = 0; i < rectList.length; ++i) {
                var point = rectList[i]
                ctx.fillRect(point.x - 4, point.y - 4, 8, 8)
            }
        }

        Connections {
            target: contentView

            function onXOffsetChanged() {
                automationCanvas.requestPaint()
            }
        }
    }

    Rectangle {
        id: selectionOverlay
        visible: automationRow.isRemoving
        x: contentView.xOffset + Math.min(removeFromBeatPrecision, removeToBeatPrecision) * contentView.pixelsPerBeatPrecision
        width: Math.abs(removeToBeatPrecision - removeFromBeatPrecision) * contentView.pixelsPerBeatPrecision
        height: parent.height
        color: "grey"
        opacity: 0.5
        border.color: "white"
        border.width: 1
    }
}