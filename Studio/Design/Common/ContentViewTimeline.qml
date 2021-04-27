import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0

Rectangle {
    property int lastHiddenIndex: Math.ceil(Math.abs(xOffset) / (contentView.beatsPerBar * surfaceContentGrid.barsPerCell * contentView.pixelsPerBeat))
    property bool isEditingLoop: false

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

        id: timelineArea

        MouseArea {
            anchors.fill: parent

            onPressedChanged: isEditingLoop = false

            onPressed: {
                contentView.timelineBeginMove((Math.abs(xOffset) + mouseX) / contentView.pixelsPerBeatPrecision)
            }

            onPositionChanged: {
                if (!containsPress)
                    return
                var beat = (Math.abs(xOffset) + mouseX) / contentView.pixelsPerBeatPrecision
                if (isEditingLoop) {
                    if (beat < contentView.loopFrom)
                        contentView.loopFrom = beat
                    else {
                        contentView.loopTo = beat
                    }
                } else
                    contentView.timelineMove(beat)
            }

            onReleased: {
                if (contentView.hasLoop && contentView.loopFrom == contentView.loopTo) {
                    contentView.disableLoopRange()
                } else
                    contentView.timelineEndMove()
            }

            onDoubleClicked: {
                isEditingLoop = true
                var beat = (Math.abs(xOffset) + mouseX) / contentView.pixelsPerBeatPrecision
                contentView.hasLoop = true
                contentView.loopFrom = beat
                contentView.loopTo = beat
            }
        }

        Rectangle {
            id: loopUnusedLeftIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: loopFromIndicator.left
            visible: contentView.hasLoop
            height: Math.max(parent.height * 0.1, 4)
            color: "grey"
        }

        Rectangle {
            id: loopFromIndicator
            x: contentView.xOffset + contentView.loopFrom * contentView.pixelsPerBeatPrecision - width / 2
            width: height
            height: parent.height
            radius: width / 2
            visible: contentView.hasLoop
            color: themeManager.accentColor

            MouseArea {
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: loopToIndicator.x

                drag.onActiveChanged: {
                    contentView.loopFrom = (loopFromIndicator.x - contentView.xOffset + loopFromIndicator.width / 2) / contentView.pixelsPerBeatPrecision
                    if (contentView.loopFrom === contentView.loopTo)
                        contentView.disableLoopRange()
                    else
                        app.scheduler.setLoopRange(AudioAPI.beatRange(contentView.loopFrom, contentView.loopTo))
                }
            }
        }

        Rectangle {
            id: loopIndicatorLink
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: loopFromIndicator.right
            anchors.right: loopToIndicator.left
            height: Math.max(parent.height * 0.1, 4)
            color: themeManager.accentColor
        }

        Rectangle {
            id: loopToIndicator
            x: contentView.xOffset + contentView.loopTo * contentView.pixelsPerBeatPrecision - width / 2
            width: height
            height: parent.height
            radius: width / 2
            visible: contentView.hasLoop
            color: themeManager.accentColor

            MouseArea {
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: loopFromIndicator.x
                drag.maximumX: timelineArea.width

                drag.onActiveChanged: {
                    contentView.loopTo = (loopToIndicator.x - contentView.xOffset + loopToIndicator.width / 2) / contentView.pixelsPerBeatPrecision
                    if (contentView.loopFrom === contentView.loopTo)
                        contentView.disableLoopRange()
                    else
                        app.scheduler.setLoopRange(AudioAPI.beatRange(contentView.loopFrom, contentView.loopTo))
                }
            }
        }

        Rectangle {
            id: loopUnusedRightIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: loopToIndicator.right
            anchors.right: parent.right
            visible: contentView.hasLoop
            height: Math.max(parent.height * 0.1, 4)
            color: "grey"
        }

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
    }
}
