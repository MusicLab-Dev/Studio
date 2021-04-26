import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property int lastHiddenIndex: Math.ceil(Math.abs(xOffset) / (contentView.beatsPerBar * surfaceContentGrid.barsPerCell * contentView.pixelsPerBeat))

    id: timeline
    color: themeManager.disabledColor

    Snapper {
        id: snapper
        width: contentView.rowHeaderWidth
        height: parent.height
    }

    Item {
        anchors.top: parent.top
        anchors.left: snapper.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        Repeater {
            width: parent.width
            height: parent.height
            model: surfaceContentGrid.cellsPerRow

            delegate: Column {
                property int beat: (lastHiddenIndex + index) * contentView.beatsPerBar * surfaceContentGrid.barsPerCell

                x: contentView.xOffset + beat * contentView.pixelsPerBeat

                Text {
                    text: beat
                    color: "black"
                }

                Rectangle {
                    height: timeline.height / 3
                    width: 1
                    color: themeManager.foregroundColor
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            onPressed: {
                contentView.timelineBeginMove((Math.abs(xOffset) + mouseX) / contentView.pixelsPerBeatPrecision)
            }

            onPositionChanged: {
                if (!containsPress)
                    return
                contentView.timelineMove((Math.abs(xOffset) + mouseX) / contentView.pixelsPerBeatPrecision)
            }

            onReleased: {
                contentView.timelineEndMove()
            }
        }
    }
}
