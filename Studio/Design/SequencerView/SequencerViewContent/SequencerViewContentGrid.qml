import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property real xOffset: 0
    property real yOffset: (1 - ((flickable.contentY % piano.rowHeight) / piano.rowHeight)) * piano.rowHeight
    property int displayedRowCount: height  / piano.rowHeight

    onDisplayedRowCountChanged: {
        canvas.requestPaint()
    }

    id: grid
    color: "#4A8693"

    Canvas {
        id: canvas
        width: parent.width
        height: parent.height
        y: yOffset

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            /*ctx.fillStyle = Qt.rgba(1, 0, 0, 1);
            ctx.fillRect(0, 0, width, height)*/
            ctx.fillStyle = Qt.rgba(0, 0, 0, 1);
            for (var i = 0; i < displayedRowCount; ++i) {
                ctx.fillRect(0, i * piano.rowHeight, width, 1);
            }
        }

        Connections {
            target: piano

            function onRowHeightChanged() {
                canvas.requestPaint()
            }
        }
    }

    Shortcut {
        sequence: StandardKey.ZoomIn
        onActivated: {
            if (piano.rowHeight < 100)
                piano.rowHeight += 2
        }
    }

    Shortcut {
        sequence: StandardKey.ZoomOut
        onActivated: {
            if (piano.rowHeight > 20)
                piano.rowHeight -= 2
        }
    }

    Slider {
        value: piano.rowHeight
        from: 20
        to: 100

        onMoved: {
            piano.rowHeight = value
        }
    }
}
