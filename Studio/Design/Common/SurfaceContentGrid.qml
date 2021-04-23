import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    // Direct inputs
    property int barsPerRow: 5
    property int beatsPerBar: 4

    // Layout inputs
    property real xOffset: 0
    property real yOffset: 0
    property real rowHeight: 30

    // Lines preferences
    property real rowThickness: 1
    property real cellThickness: 1
    property real divisionThickness: 1
    property color rowColor: Qt.rgba(0.12, 0.12, 0.12, 1)
    property color cellColor: Qt.rgba(0.12, 0.12, 0.12, 1)
    property color divisionColor: Qt.rgba(0.25, 0.25, 0.25, 1)

    // Intermediate calculus
    readonly property real xRowOffset: xOffset % width
    readonly property real yRowOffset: yOffset % rowHeight

    // Vertical display logic
    readonly property int rowsPerColumn: height / rowHeight

    // Horizontal display logic
    readonly property int barsPerRowThreshold: 4
    readonly property int cellsPerRowThreshold: 4
    readonly property int barsPerCell: barsPerRow <= barsPerRowThreshold ? 1 : Math.floor(barsPerRow / cellsPerRowThreshold)
    readonly property int cellsPerRow: barsPerCell === 1 ? barsPerRow : cellsPerRowThreshold
    readonly property int divisionsPerCell: barsPerCell === 1 ? beatsPerBar : barsPerCell

    // Final horizontal layout values
    readonly property real cellWidth: width / cellsPerRow
    readonly property real divisionWidth: cellWidth / divisionsPerCell

    clip: true

    onRowHeightChanged: canvasRows.requestPaint()
    onBarsPerRowChanged: canvasColumns.requestPaint()

    Canvas {
        id: canvasRows
        y: yRowOffset
        width: parent.width
        height: parent.height

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var offset = 0
            ctx.reset()
            ctx.fillStyle = rowColor
            for (var i = 0; i <= rowsPerColumn; ++i) {
                ctx.fillRect(0, offset, width, rowThickness)
                offset += rowHeight
            }
        }
    }

    Canvas {
        id: canvasColumns
        x: xRowOffset
        width: parent.width * 2
        height: parent.height

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var offset = 0
            var i = 0
            var cellsToDraw = cellsPerRow * 2
            ctx.fillStyle = cellColor
            // Draw cells
            for (; i < cellsToDraw; ++i) {
                ctx.fillRect(offset, 0, cellThickness, height)
                offset += cellWidth
            }
            offset = 0
            ctx.fillStyle = divisionColor
            // Draw subcells
            var divisionCount = divisionsPerCell - 1
            for (i = 0; i < cellsToDraw; ++i) {
                for (var j = 0; j < divisionCount; ++j) {
                    offset += divisionWidth
                    ctx.fillRect(offset, 0, divisionThickness, height)
                }
                offset += divisionWidth
            }
        }
    }
}
