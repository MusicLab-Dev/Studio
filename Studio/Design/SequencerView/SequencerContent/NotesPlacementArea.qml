import QtQuick 2.15
import QtQuick.Controls 2.15

import PartitionModel 1.0
import AudioAPI 1.0

MouseArea {
    enum Mode {
        None,
        Remove,
        Move,
        LeftResize,
        RightResize
    }

    property PartitionModel partition: null
    property int mode: NotesPlacementArea.Mode.None

    id: contentPlacementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    clip: true

    onPressed: {
        var realMouseBeatPrecision = (mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision
        var mouseKey = pianoView.keyOffset + Math.floor((height - mouse.y) / contentView.rowHeight)
        var mouseBeatPrecision = realMouseBeatPrecision
        var noteIndex = partition.find(mouseKey, mouseBeatPrecision)
        if (mouse.buttons & Qt.RightButton) { // Right click on note -> delete
            mode = NotesPlacementArea.Mode.Remove
            if (noteIndex !== -1)
                partition.remove(noteIndex)
            return
        }
        if (contentView.placementBeatPrecisionScale !== 0)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)
        contentView.placementRectangle.attach(contentPlacementArea, themeManager.getColorFromChain(mouseKey))
        if (noteIndex === -1) { // Left click not on note -> insert
            mode = NotesPlacementArea.Mode.Move
            contentView.placementBeatPrecisionTo = mouseBeatPrecision + contentView.placementBeatPrecisionDefaultWidth
            contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            contentView.placementKey = mouseKey
        } else { // Left click on note -> edit
            var beatPrecisionRange = partition.getNote(noteIndex).range
            var noteWidth = (beatPrecisionRange.to - beatPrecisionRange.from) * contentView.pixelsPerBeatPrecision
            var resizeThreshold = Math.min(noteWidth * 0.2, contentView.placementResizeMaxPixelThreshold)
            if ((realMouseBeatPrecision - beatPrecisionRange.from) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = NotesPlacementArea.Mode.LeftResize
            else if ((beatPrecisionRange.to - realMouseBeatPrecision) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = NotesPlacementArea.Mode.RightResize
            else
                mode = NotesPlacementArea.Mode.Move
            partition.remove(noteIndex)
            contentView.placementBeatPrecisionFrom = beatPrecisionRange.from
            contentView.placementBeatPrecisionTo = beatPrecisionRange.to
            contentView.placementBeatPrecisionMouseOffset = mouseBeatPrecision - beatPrecisionRange.from
            contentView.placementKey = mouseKey
        }
    }

    onReleased: {
        switch (mode) {
        case NotesPlacementArea.Mode.Move:
        case NotesPlacementArea.Mode.LeftResize:
        case NotesPlacementArea.Mode.RightResize:
            if (contentView.placementBeatPrecisionFrom < 0)
                contentView.placementBeatPrecisionFrom = 0
            partition.add(
                AudioAPI.note(
            /* Range    */  AudioAPI.beatRange(contentView.placementBeatPrecisionFrom, contentView.placementBeatPrecisionTo),
            /* Key      */  contentView.placementKey,
            /* Velocity */  AudioAPI.velocityMax,
            /* Tuning   */  0
                )
            )
            contentView.placementBeatPrecisionMouseOffset = 0
            break;
        default:
            break;
        }
        contentView.placementRectangle.detach()
        mode = NotesPlacementArea.Mode.None
    }

    onPositionChanged: {
        var mouseBeatPrecision = (mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision
        var mouseKey = pianoView.keyOffset + Math.floor((height - mouse.y) / contentView.rowHeight)
        if (contentView.placementBeatPrecisionScale !== 0)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)
        switch (mode) {
        case NotesPlacementArea.Mode.Remove:
            var noteIndex = partition.find(mouseKey, mouseBeatPrecision)
            if (noteIndex !== -1)
                partition.remove(noteIndex)
            break
        case NotesPlacementArea.Mode.Move:
            var beatPrecision = mouseBeatPrecision - contentView.placementBeatPrecisionMouseOffset
            contentView.placementBeatPrecisionTo = beatPrecision + contentView.placementBeatPrecisionWidth
            contentView.placementBeatPrecisionFrom = beatPrecision
            if (contentView.placementKey != mouseKey)
                contentView.placementRectangle.targetColor = themeManager.getColorFromChain(mouseKey)
            contentView.placementKey = mouseKey
            break
        case NotesPlacementArea.Mode.LeftResize:
            if (contentView.placementBeatPrecisionTo > mouseBeatPrecision)
                contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            else
                mode = NotesPlacementArea.Mode.RightResize
            break
        case NotesPlacementArea.Mode.RightResize:
            if (contentView.placementBeatPrecisionFrom < mouseBeatPrecision)
                contentView.placementBeatPrecisionTo = mouseBeatPrecision
            else
                mode = NotesPlacementArea.Mode.LeftResize
            break
        default:
            break
        }
    }
}