import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../Default/"
import "../Common"
import "./PlaylistContent"

Column {
    property alias contentView: contentView

    id: playlistViewContent
    spacing: 0

    ContentTimeline {
        id: timeline
        width: parent.width
        height: Math.min(Math.max(parent.height * 0.03, 20, 30))
        headerWidth: contentView.rowHeaderWidth

        Row {
            Slider {
                from: contentView.xOffsetMin
                to: contentView.xOffsetMax
                value: contentView.xOffset
                onMoved: {
                    contentView.xOffset = value
                }
            }

            Slider {
                from: contentView.yOffsetMin
                to: contentView.yOffsetMax
                value: contentView.yOffset
                onMoved: {
                    contentView.yOffset = value
                }
            }

            Slider {
                from: 0
                to: 1
                value: contentView.xZoom
                stepSize: 0.01
                onMoved: {
                    contentView.xZoom = value
                }
            }

            Slider {
                from: 0
                to: 1
                value: contentView.yZoom
                stepSize: 0.01
                onMoved: {
                    contentView.yZoom = value
                }
            }

            DefaultText {
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                text: {
                    if (contentView.surfaceContentGrid.barsPerCell > 1) {
                        return "1 Cell = " + contentView.surfaceContentGrid.barsPerCell + " bars = "
                            + contentView.surfaceContentGrid.beatsPerBar * contentView.surfaceContentGrid.barsPerCell + " beats ("
                            + contentView.surfaceContentGrid.cellsPerRow + " : " + contentView.surfaceContentGrid.divisionsPerCell + ")"
                    } else {
                        return "1 Cell = 1 bar = " + contentView.surfaceContentGrid.beatsPerBar + " beats ("
                            + contentView.surfaceContentGrid.cellsPerRow + " : " + contentView.surfaceContentGrid.divisionsPerCell + ")"
                    }
                }
            }
        }
    }

    PlaylistContentView {
        id: contentView
        width: parent.width
        height: parent.height - timeline.height
    }
}
