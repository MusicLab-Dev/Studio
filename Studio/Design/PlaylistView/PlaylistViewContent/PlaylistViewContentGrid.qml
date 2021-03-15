import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property real xOffset: 0
    property real yOffset: (1 - ((flickable.contentY % playlistViewContentFlickable.rowHeight) / playlistViewContentFlickable.rowHeight)) * playlistViewContentFlickable.rowHeight
    property int displayedRowCount: height / rowHeight

    // Input
    property int barsPerLine: 5

    property int beatsPerBar: 4
    readonly property int barsPerLineThreshold: 4
    readonly property int barsPerCellThreshold: 4
    property int barsPerCell: {
        if (barsPerLine <= barsPerLineThreshold)
            return 1;
        var divCount = Math.ceil(barsPerLine / barsPerCellThreshold);
        if (divCount < barsPerCellThreshold)
            return divCount;
        else
            return barsPerCellThreshold;
    }

    property int cellsPerLine: barsPerCell === 1 ? barsPerLine : barsPerLine / barsPerCell
    property int divisionsPerCell: barsPerCell === 1 ? beatsPerBar : barsPerCell

    property real cellWidth: width / cellsPerLine
    property real divisionWidth: cellWidth / divisionsPerCell

    id: grid
    color: themeManager.backgroundColor

    onDisplayedRowCountChanged: {
        canvasHorizontal.requestPaint()
    }

    onBarsPerLineChanged: canvasVertical.requestPaint()

    Canvas {
        id: canvasHorizontal
        width: parent.width
        height: parent.height
        y: yOffset

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = Qt.rgba(0, 0, 0, 1);
            for (var i = 0; i < displayedRowCount; ++i) {
                ctx.fillRect(0, i * playlistViewContentFlickable.rowHeight, width, 1);
            }
        }
    }

    Canvas {
        anchors.fill: parent

        id: canvasVertical
        width: parent.width
        height: parent.height

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var offset = xOffset
            var i = 0
            ctx.fillStyle = Qt.rgba(0, 0, 0, 0.5)
            // Draw cells
            for (; i < cellsPerLine; ++i) {
                ctx.fillRect(offset, 0, 1, height)
                offset += cellWidth
            }
            offset = xOffset
            ctx.fillStyle = Qt.rgba(0, 0, 0, 0.25)
            // Draw subcells
            var divisionCount = divisionsPerCell - 1
            for (i = 0; i < cellsPerLine; ++i) {
                for (var j = 0; j < divisionCount; ++j) {
                    offset += divisionWidth
                    ctx.fillRect(offset, 0, 1, height)
                }
                offset += divisionWidth
            }
        }
    }
}

