import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

import "../Help"

import AudioAPI 1.0

Item {
    enum EditMode {
        None,
        Playback,
        Loop,
        InvertedLoop
    }

    function ensureTimelineBeatPrecision(beat) {
        return beat - (beat % (AudioAPI.beatPrecision / 4))
    }

    property int editMode: ContentViewTimeline.EditMode.None
    property alias timelineCursor: timelineCursor
    readonly property real loopFromIndicatorX: loopFromIndicator.x + loopFromIndicator.width / 2
    readonly property real loopToIndicatorX: loopToIndicator.x + loopToIndicator.width / 2
    property Player player

    id: timeline

    Rectangle {
        id: actionBox
        width: contentView.rowHeaderWidth
        height: parent.height
        color: themeManager.backgroundColor
        border.color: "black"
        border.width: 1
    }

    Item {
        anchors.top: parent.top
        anchors.left: actionBox.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        id: timelineArea

        HelpArea {
            name: qsTr("Timeline")
            description: qsTr("Change the project name on clicked")
            position: HelpHandler.Position.Bottom
            externalDisplay: true
        }

        MouseArea {
            function getMouseBeatPrecision() {
                return ensureTimelineBeatPrecision(
                    (Math.abs(contentView.xOffset) + mouseX) / contentView.pixelsPerBeatPrecision
                )
            }

            id: timelineMouseArea
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent

            onPressed: {
                forceActiveFocus()
                if (mouse.buttons & Qt.RightButton) {
                    player.disableLoopRange()
                    return
                }
                var beat = getMouseBeatPrecision()
                if (mouse.modifiers & Qt.ShiftModifier || mouse.modifiers & Qt.ControlModifier) {
                    if (beat >= player.playFrom) {
                        editMode = ContentViewTimeline.EditMode.Loop
                        player.timelineBeginLoopMove(player.playFrom, beat)
                    } else {
                        editMode = ContentViewTimeline.EditMode.InvertedLoop
                        player.timelineBeginLoopMove(beat, player.playFrom)
                    }
                } else {
                    editMode = ContentViewTimeline.EditMode.Playback
                    player.timelineBeginMove(beat)
                }
            }

            onPositionChanged: {
                if (!pressed || mouse.buttons & Qt.RightButton)
                    return
                var beat = getMouseBeatPrecision()
                switch (editMode) {
                case ContentViewTimeline.EditMode.Playback:
                    player.timelineMove(beat)
                    break
                case ContentViewTimeline.EditMode.Loop:
                    if (beat >= player.loopFrom)
                        player.timelineLoopMove(beat)
                    else
                        player.timelineLoopMove(player.loopFrom)
                    break
                case ContentViewTimeline.EditMode.InvertedLoop:
                    if (beat <= player.loopTo)
                        player.timelineInvertedLoopMove(beat)
                    else
                        player.timelineInvertedLoopMove(player.loopTo)
                    break
                default:
                    break
                }
            }

            onReleased: {
                if (mouse.buttons & Qt.RightButton)
                    return
                switch (editMode) {
                case ContentViewTimeline.EditMode.Playback:
                    player.timelineEndMove()
                    break
                case ContentViewTimeline.EditMode.Loop:
                case ContentViewTimeline.EditMode.InvertedLoop:
                    player.timelineEndLoopMove()
                    break
                default:
                    break
                }
                editMode = ContentViewTimeline.EditMode.None
            }
        }

        Rectangle {
            id: upTimeline
            height: parent.height / 2
            width: parent.width
            color: "#00ECBA"

            ContentViewTimelineBarCursor {
                id: timelineCursor
                x: timelineBar.x - actionBox.width - width / 2
            }

            ContentViewTimelineBarCursor {
                id: playFromCursor
                color: themeManager.accentColor
                x: playFromBar.x - actionBox.width - width / 2
                opacity: 0.6
            }
        }

        Rectangle {
            id: bottomTimeline
            height: parent.height / 2
            width: parent.width
            anchors.top: upTimeline.bottom
            color: themeManager.foregroundColor
        }

        Rectangle {
            id: loopUnusedLeftIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: loopFromIndicator.left
            visible: player.hasLoop
            height: Math.max(parent.height * 0.1, 4)
            color: "grey"
        }

        Rectangle {
            id: loopFromIndicator
            x: contentView.xOffset + player.loopFrom * contentView.pixelsPerBeatPrecision - width / 2
            width: height
            height: parent.height
            radius: width / 2
            visible: player.hasLoop
            color: themeManager.accentColor

            MouseArea {
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: -width / 2
                drag.maximumX: loopToIndicator.x

                drag.onActiveChanged: {
                    if (drag.active)
                        player.timelineBeginLoopMove(player.loopFrom, player.loopTo)
                    else {
                        var beat = (loopFromIndicator.x - contentView.xOffset + loopFromIndicator.width / 2) / contentView.pixelsPerBeatPrecision
                        player.timelineInvertedLoopMove(ensureTimelineBeatPrecision(beat))
                        player.timelineEndLoopMove()
                    }
                }

                onPressedChanged: forceActiveFocus()
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
            x: contentView.xOffset + player.loopTo * contentView.pixelsPerBeatPrecision - width / 2
            width: height
            height: parent.height
            radius: width / 2
            visible: player.hasLoop
            color: themeManager.accentColor

            MouseArea {
                anchors.fill: parent
                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: loopFromIndicator.x
                drag.maximumX: timelineArea.width - width / 2

                drag.onActiveChanged: {
                    if (drag.active)
                        player.timelineBeginLoopMove(player.loopFrom, player.loopTo)
                    else {
                        var beat = (loopToIndicator.x - contentView.xOffset + loopToIndicator.width / 2) / contentView.pixelsPerBeatPrecision
                        player.timelineLoopMove(ensureTimelineBeatPrecision(beat))
                        player.timelineEndLoopMove()
                    }
                }

                onPressedChanged: forceActiveFocus()
            }
        }

        Rectangle {
            id: loopUnusedRightIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: loopToIndicator.right
            anchors.right: parent.right
            visible: player.hasLoop
            height: Math.max(parent.height * 0.1, 4)
            color: "grey"
        }

        Item {
            id: bottomTimelineItem
            y: bottomTimeline.y
            width: bottomTimeline.width
            height: bottomTimeline.height

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

                delegate: Text {
                    readonly property int reducedIndex: timelineRepeater.lastHiddenBarIndex + index * (timelineRepeater.barSkipStep + 1)
                    readonly property int beat: reducedIndex * contentView.beatsPerBar

                    x: contentView.xOffset + beat * contentView.pixelsPerBeat
                    anchors.verticalCenter: bottomTimelineItem.verticalCenter
                    text: reducedIndex
                    color: "white"
                    font.pixelSize: parent.height
                }
            }
        }
    }
}
