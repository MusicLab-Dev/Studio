import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property int barsPerRow: 0
    property real xOffset: 0
    readonly property int barsPerRowThreshold: 4
    readonly property int cellsPerRowThreshold: 4
    readonly property int barsPerCell: barsPerRow <= barsPerRowThreshold ? 1 : Math.floor(barsPerRow / cellsPerRowThreshold)
    readonly property int cellsPerRow: barsPerCell === 1 ? barsPerRow : cellsPerRowThreshold
    readonly property real cellWidth: width / cellsPerRow
    readonly property real divisionWidth: cellWidth / divisionsPerCell
    readonly property int divisionsPerCell: barsPerCell === 1 ? beatsPerBar : barsPerCell

    color: themeManager.disabledColor


    Repeater {
        width: parent.width * 2
        height: parent.height
        model: cellsPerRow * 2

        Text {
            text: index
            color: "black"
            x: index * cellWidth - width / 2 + xOffset
        }
    }

    onBarsPerCellChanged: {
        canvasColumns.requestPaint()
    }

    Canvas {
        id: canvasColumns
        height: parent.height / 3
        width: parent.width * 2
        x: xOffset
        anchors.bottom: parent.bottom
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var offset = 0
            var i = 0
            var cellsToDraw = cellsPerRow * 2
            ctx.fillStyle = "black"
            for (; i < cellsToDraw; ++i) {
                ctx.fillRect(offset, 0, 1, height)
                offset += cellWidth
            }
            offset = 0
            ctx.fillStyle = "grey"
            var divisionCount = divisionsPerCell - 1
            for (i = 0; i < cellsToDraw; ++i) {
                for (var j = 0; j < divisionCount; ++j) {
                    offset += divisionWidth
                    ctx.fillRect(offset, 0, 1, height)
                }
                offset += divisionWidth
            }
        }
    }
}
