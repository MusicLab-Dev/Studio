import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

import AudioAPI 1.0

Rectangle {
    property bool isEditingLoop: false

    id: timeline
    color: themeManager.disabledColor

    Snapper {
        id: snapper
        width: contentView.rowHeaderWidth
        height: parent.height
        currentIndex: 4

        onActivated: {
            contentView.placementBeatPrecisionScale = currentValue
            contentView.placementBeatPrecisionLastWidth = 0
        }
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

            onPressedChanged: {
                if (pressed) {
                    contentView.timelineBeginMove((Math.abs(contentView.xOffset) + mouseX) / contentView.pixelsPerBeatPrecision)
                } else {
                    isEditingLoop = false
                    if (contentView.hasLoop && contentView.loopFrom == contentView.loopTo) {
                        contentView.disableLoopRange()
                    } else
                        contentView.timelineEndMove()
                }
            }

            onPositionChanged: {
                if (!containsPress)
                    return
                var beat = (Math.abs(contentView.xOffset) + mouseX) / contentView.pixelsPerBeatPrecision
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
                var beat = (Math.abs(contentView.xOffset) + mouseX) / contentView.pixelsPerBeatPrecision
                contentView.hasLoop = true
                contentView.loopFrom = beat
                contentView.loopTo = beat
            }
        }

        ContentViewTimelineBarCursor {
            id: shape
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
                drag.minimumX: -width / 2
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
                drag.maximumX: timelineArea.width - width / 2

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
            readonly property int lastHiddenBarIndex: {
                var idx = Math.floor(Math.abs(contentView.xOffset) / (surfaceContentGrid.barWidth))
                if (barSkipStep)
                    idx = idx - (idx % (barSkipStep + 1))
                return idx
            }
            readonly property int barModel: Math.max(surfaceContentGrid.barsPerRow, 1)
            readonly property int barSkipStep: Math.floor(surfaceContentGrid.barsPerRow / 40)
            readonly property int barReducedModel: Math.ceil(barModel / (barSkipStep + 1)) + 1

            id: timelineRepeater
            width: parent.width
            height: parent.height
            model: barReducedModel

            delegate: Column {
                readonly property int reducedIndex: timelineRepeater.lastHiddenBarIndex + index * (timelineRepeater.barSkipStep + 1)
                readonly property int beat: reducedIndex * contentView.beatsPerBar

                x: contentView.xOffset + beat * contentView.pixelsPerBeat

                Text {
                    text: reducedIndex
                    color: "black"
                }

                Rectangle {
                    width: 1
                    height: timeline.height / 3
                    color: themeManager.foregroundColor
                }
            }
        }
    }
}
