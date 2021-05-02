import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    // Format inputs
    property int barsPerGroup: 4
    property int beatsPerBar: 4

    // Layout inputs
    property int beatsPerRow: 5
    property real xOffset: 0
    property real yOffset: 0
    property real rowHeight: 30

    // Lines preferences
    property real rowThickness: 1
    property real barThickness: divisionsPerBar ? 2 : 1
    property real beatThickness: divisionsPerBeat ? 2 : 1
    property real divisionThickness: 1
    property color rowColor: "#041A25"
    property color groupAColor: themeManager.backgroundColor
    property color groupBColor: Qt.lighter(groupAColor, 1.33)
    property color barColor: rowColor
    property color beatColor: "#162C37"
    property color divisionColor: "#253A45"

    // Intermediate calculus
    readonly property real xGroupOffset: xOffset % groupMarginWidth
    readonly property real xRowOffset: xOffset % width
    readonly property real yRowOffset: yOffset % rowHeight

    // Vertical display logic
    readonly property int rowsPerColumn: height / rowHeight

    // Horizontal display logic
    readonly property real groupsPerRow: beatsPerRow / (beatsPerBar * barsPerGroup)
    readonly property real barsPerRow: Math.max(beatsPerRow / beatsPerBar, 0.5)
    readonly property int divisionsPerBar: barsPerRow > 48 ? 0 : barsPerRow > 32 ? 2 : 4
    readonly property int divisionsPerBeat: barsPerRow > 16 ? 0 : barsPerRow > 8 ? 2 : 4

    // Final horizontal layout values
    readonly property real groupWidth: barWidth * barsPerGroup
    readonly property real groupMarginWidth: groupWidth * 2
    readonly property real barWidth: barsPerRow ? width / barsPerRow : 0
    readonly property real beatWidth: width / beatsPerRow
    readonly property real divisionWidth: divisionsPerBeat ? beatWidth / divisionsPerBeat : 0
    readonly property real beatCellWidth: barWidth / divisionsPerBar
    readonly property real divisionCellWidth: beatCellWidth / divisionsPerBeat

    clip: true

    onWidthChanged: canvasRows.requestPaint()
    onHeightChanged: {
        canvasColumns.requestPaint()
        canvasGroups.requestPaint()
    }
    onBeatsPerRowChanged:  {
        canvasColumns.requestPaint()
        canvasGroups.requestPaint()
    }
    onRowHeightChanged: canvasRows.requestPaint()

    Canvas {
        id: canvasGroups
        x: xGroupOffset
        width: parent.width + groupMarginWidth
        height: parent.height

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var offset = 0
            // Draw groups
            var groupsToDraw = Math.ceil(width / groupWidth)
            var groupA = true
            for (var i = 0; i < groupsToDraw; ++i) {
                ctx.fillStyle = groupA ? groupAColor : groupBColor
                groupA = !groupA
                ctx.fillRect(offset, 0, groupWidth, height)
                offset += groupWidth
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
            var barsToDraw = barsPerRow * 2
            var offset = 0
            var i = 0
            var group = 0
            // Draw Bars
            offset = 0
            ctx.fillStyle = barColor
            if (divisionsPerBar !== 0) {
                for (i = 0; i < barsToDraw; ++i) {
                    ctx.fillRect(offset, 0, barThickness, height)
                    offset += barWidth
                }
            } else {
                for (i = 0; i < barsToDraw; ++i) {
                    ctx.fillRect(offset, 0, group === 0 ? 2 : barThickness, height)
                    offset += barWidth
                    if (++group >= barsPerGroup)
                        group = 0
                }
            }
            // Draw Beats
            if (divisionsPerBar !== 0) {
                offset = 0
                ctx.fillStyle = beatColor
                for (i = 0; i < barsToDraw; ++i) {
                    for (var j = 1; j < divisionsPerBar; ++j) {
                        offset += beatCellWidth
                        ctx.fillRect(offset, 0, beatThickness, height)
                    }
                    offset += beatCellWidth
                }
                // Draw beat divisions
                if (divisionsPerBeat !== 0) {
                    offset = 0
                    ctx.fillStyle = divisionColor
                    for (i = 0; i < barsToDraw; ++i) {
                        for (var j = 0; j < divisionsPerBar; ++j) {
                            for (var k = 1; k < divisionsPerBeat; ++k) {
                                offset += divisionCellWidth
                                ctx.fillRect(offset, 0, divisionThickness, height)
                            }
                            offset += divisionCellWidth
                        }
                    }
                }
            }
        }
    }

    Canvas {
        id: canvasRows
        y: yRowOffset
        width: parent.width
        height: parent.height

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var offset = 0
            ctx.fillStyle = rowColor
            for (var i = 0; i <= rowsPerColumn; ++i) {
                ctx.fillRect(0, offset, width, rowThickness)
                offset += rowHeight
            }
        }
    }
}
