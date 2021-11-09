import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0
import CursorManager 1.0

// The function 'getMouseBeatPrecision()' must be implemented
MouseArea {
    enum EditMode {
        None,
        Playback,
        Loop,
        InvertedLoop
    }

    function getMouseBeatPrecision() {
        var mx = Math.max(Math.min(mouseX, width), 0)
        return ensureTimelineBeatPrecision(
            (Math.abs(xOffset) + mx) / pixelsPerBeatPrecision
        )
    }

    function ensureTimelineBeatPrecision(beat) {
        return beat - (beat % (AudioAPI.beatPrecision / 4))
    }

    // Edit mode
    property int editMode: ContentViewTimelineMouseArea.EditMode.None

    // Inputs
    property PlayerBase playerBase
    property real pixelsPerBeatPrecision
    property real xOffset: 0

    id: timelineMouseArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true

    onHoveredChanged: {
        if (containsMouse)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    onPressed: {
        forceActiveFocus()
        if (mouse.buttons & Qt.RightButton) {
            playerBase.disableLoopRange()
            return
        }
        var beat = getMouseBeatPrecision()
        if (mouse.modifiers & Qt.ShiftModifier || mouse.modifiers & Qt.ControlModifier) {
            if (beat >= playerBase.playFrom) {
                editMode = ContentViewTimelineMouseArea.EditMode.Loop
                playerBase.timelineBeginLoopMove(playerBase.playFrom, beat)
            } else {
                editMode = ContentViewTimelineMouseArea.EditMode.InvertedLoop
                playerBase.timelineBeginLoopMove(beat, playerBase.playFrom)
            }
        } else {
            editMode = ContentViewTimelineMouseArea.EditMode.Playback
            playerBase.timelineBeginMove(beat)
        }
    }

    onDoubleClicked: playerBase.disableLoopRange()

    onPositionChanged: {
        if (!pressed || mouse.buttons & Qt.RightButton)
            return
        var beat = getMouseBeatPrecision()
        switch (editMode) {
        case ContentViewTimelineMouseArea.EditMode.Playback:
            playerBase.timelineMove(beat)
            break
        case ContentViewTimelineMouseArea.EditMode.Loop:
            if (beat >= playerBase.loopFrom)
                playerBase.timelineLoopMove(beat)
            else
                playerBase.timelineLoopMove(playerBase.loopFrom)
            break
        case ContentViewTimelineMouseArea.EditMode.InvertedLoop:
            if (beat <= playerBase.loopTo)
                playerBase.timelineInvertedLoopMove(beat)
            else
                playerBase.timelineInvertedLoopMove(playerBase.loopTo)
            break
        default:
            break
        }
    }

    onReleased: {
        if (mouse.buttons & Qt.RightButton)
            return
        switch (editMode) {
        case ContentViewTimelineMouseArea.EditMode.Playback:
            playerBase.timelineEndMove()
            break
        case ContentViewTimelineMouseArea.EditMode.Loop:
        case ContentViewTimelineMouseArea.EditMode.InvertedLoop:
            playerBase.timelineEndLoopMove()
            break
        default:
            break
        }
        editMode = ContentViewTimelineMouseArea.EditMode.None
    }
}
