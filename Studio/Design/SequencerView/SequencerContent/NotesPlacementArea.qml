import QtQuick 2.15
import QtQuick.Controls 2.15

import Scheduler 1.0
import PartitionModel 1.0
import AudioAPI 1.0

import ".."

MouseArea {
    enum Mode {
        None,
        Remove,
        Move,
        LeftResize,
        RightResize,
        Brush,
        BrushLeft,
        BrushRight
    }

    property PartitionModel partition: null
    property int mode: NotesPlacementArea.Mode.None
    property int onTheFlyKey: -1
    property int brushKey: 0
    property int brushBegin: 0
    property int brushEnd: 0
    property int brushStep: 0
    property int brushWidth: 0

    function addOnTheFly(targetKey) {
        if (onTheFlyKey !== -1 && onTheFlyKey !== targetKey)
            removeOnTheFly(onTheFlyKey)
        onTheFlyKey = targetKey
        sequencerView.node.partitions.addOnTheFly(
            AudioAPI.noteEvent(
                NoteEvent.On,
                targetKey,
                AudioAPI.velocityMax,
                0
            ),
            sequencerView.node,
            sequencerView.partitionIndex
        )
    }

    function removeOnTheFly(targetKey) {
        sequencerView.node.partitions.addOnTheFly(
            AudioAPI.noteEvent(
                NoteEvent.Off,
                targetKey,
                0,
                0
            ),
            sequencerView.node,
            sequencerView.partitionIndex
        )
        onTheFlyKey = -1
    }

    id: contentPlacementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    clip: true

    onPressed: {
        var realMouseBeatPrecision = Math.floor((mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
        var mouseKey = pianoView.keyOffset + Math.floor((height - mouse.y) / contentView.rowHeight)
        var noteIndex = partition.find(mouseKey, realMouseBeatPrecision)

        // Right click on note -> delete
        if (mouse.buttons & Qt.RightButton) {
            mode = NotesPlacementArea.Mode.Remove
            if (noteIndex !== -1)
                partition.remove(noteIndex)
            return
        }

        // Add an on the fly note if the sequencer isn't playing
        if (!sequencerView.player.isPlaying)
            addOnTheFly(mouseKey)

        var mouseBeatPrecision = realMouseBeatPrecision
        if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % AudioAPI.beatPrecision)
        else if (contentView.placementBeatPrecisionScale !== 0)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)

        // Left click not on note -> insert
        if (noteIndex === -1) {
            if (contentView.placementBeatPrecisionLastWidth === 0)
                contentView.placementBeatPrecisionLastWidth = contentView.placementBeatPrecisionDefaultWidth
            // Brush mode, insert note directly
            if (sequencerView.editMode === SequencerView.EditMode.Brush) {
                mode = NotesPlacementArea.Mode.Brush
                brushKey = mouseKey
                brushBegin = mouseBeatPrecision
                brushWidth = contentView.placementBeatPrecisionLastWidth + brushStep
                brushEnd = mouseBeatPrecision + brushWidth
                partition.add(
                    AudioAPI.note(
                        AudioAPI.beatRange(brushBegin, brushBegin + contentView.placementBeatPrecisionLastWidth),
                        brushKey,
                        AudioAPI.velocityMax,
                        0
                    )
                )
            // Move mode, attach preview
            } else {
                // Attach the preview
                contentView.placementRectangle.attach(contentPlacementArea, themeManager.getColorFromChain(mouseKey))
                mode = NotesPlacementArea.Mode.Move
                contentView.placementBeatPrecisionTo = mouseBeatPrecision + contentView.placementBeatPrecisionLastWidth
                contentView.placementBeatPrecisionFrom = mouseBeatPrecision
                contentView.placementKey = mouseKey
            }
        // Left click on note -> edit
        } else {
            var beatPrecisionRange = partition.getNote(noteIndex).range
            var noteWidthBeatPrecision = (beatPrecisionRange.to - beatPrecisionRange.from)
            var noteWidth = noteWidthBeatPrecision * contentView.pixelsPerBeatPrecision
            var resizeThreshold = Math.min(noteWidth * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
            contentView.placementBeatPrecisionLastWidth = noteWidthBeatPrecision
            if ((realMouseBeatPrecision - beatPrecisionRange.from) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = NotesPlacementArea.Mode.LeftResize
            else if ((beatPrecisionRange.to - realMouseBeatPrecision) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = NotesPlacementArea.Mode.RightResize
            else
                mode = NotesPlacementArea.Mode.Move
            partition.remove(noteIndex)
            // Attach the preview
            contentView.placementRectangle.attach(contentPlacementArea, themeManager.getColorFromChain(mouseKey))
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
            contentView.placementBeatPrecisionLastWidth = contentView.placementBeatPrecisionWidth
            partition.add(
                AudioAPI.note(
                    AudioAPI.beatRange(contentView.placementBeatPrecisionFrom, contentView.placementBeatPrecisionTo),
                    contentView.placementKey,
                    AudioAPI.velocityMax,
                    0
                )
            )
            contentView.placementBeatPrecisionMouseOffset = 0
            break;
        default:
            break;
        }
        contentView.placementRectangle.detach()
        mode = NotesPlacementArea.Mode.None
        if (onTheFlyKey !== -1)
            removeOnTheFly(onTheFlyKey)
    }

    onPositionChanged: {
        var realMouseBeatPrecision = Math.floor((mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
        var mouseKey = pianoView.keyOffset + Math.floor((height - mouse.y) / contentView.rowHeight)
        switch (mode) {
        case NotesPlacementArea.Mode.Remove:
            var noteIndex = partition.find(mouseKey, realMouseBeatPrecision)
            if (noteIndex !== -1)
                partition.remove(noteIndex)
            break
        case NotesPlacementArea.Mode.Move:
            var mouseBeatPrecision = realMouseBeatPrecision - contentView.placementBeatPrecisionMouseOffset
            if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % AudioAPI.beatPrecision)
            else if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)
            contentView.placementBeatPrecisionTo = mouseBeatPrecision + contentView.placementBeatPrecisionWidth
            contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            if (contentView.placementKey !== mouseKey) {
                contentView.placementRectangle.targetColor = themeManager.getColorFromChain(mouseKey)
                if (!sequencerView.player.isPlaying)
                    addOnTheFly(mouseKey)
                contentView.placementKey = mouseKey
            }
            break
        case NotesPlacementArea.Mode.LeftResize:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale) + (contentView.placementBeatPrecisionFrom % contentView.placementBeatPrecisionScale)
            if (contentView.placementBeatPrecisionTo > mouseBeatPrecision)
                contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            else
                mode = NotesPlacementArea.Mode.RightResize
            break
        case NotesPlacementArea.Mode.RightResize:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision + (contentView.placementBeatPrecisionScale - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)) + (contentView.placementBeatPrecisionTo % contentView.placementBeatPrecisionScale)
            if (contentView.placementBeatPrecisionFrom < mouseBeatPrecision)
                contentView.placementBeatPrecisionTo = mouseBeatPrecision
            else
                mode = NotesPlacementArea.Mode.LeftResize
            break
        case NotesPlacementArea.Mode.Brush:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (mouseBeatPrecision >= brushBegin && mouseBeatPrecision <= brushEnd)
                return
            if (mouseBeatPrecision <= brushBegin)
                mouseBeatPrecision = mouseBeatPrecision + (brushBegin - mouseBeatPrecision) - brushWidth
            else
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision - brushEnd)
            brushBegin = mouseBeatPrecision
            brushEnd = mouseBeatPrecision + brushWidth

            // Don't brush over existing notes
            if (brushBegin >= 0 && partition.findOverlap(brushKey, brushBegin + 1, brushBegin + contentView.placementBeatPrecisionLastWidth - 1) === -1) {
                if (!sequencerView.player.isPlaying)
                    addOnTheFly(brushKey)
                partition.add(
                    AudioAPI.note(
                        AudioAPI.beatRange(brushBegin, brushBegin + contentView.placementBeatPrecisionLastWidth),
                        brushKey,
                        AudioAPI.velocityMax,
                        0
                    )
                )
            }
            break
        default:
            break
        }
    }

    Rectangle {
        color: "transparent"
        border.color: Qt.darker(themeManager.getColorFromChain(brushKey), 1.5)
        border.width: 2
        visible: mode == NotesPlacementArea.Mode.Brush
        x: contentView.xOffset + brushBegin * contentView.pixelsPerBeatPrecision
        y: parent.height - (brushKey - pianoView.keyOffset + 1) * contentView.rowHeight
        width: (brushEnd - brushBegin) * contentView.pixelsPerBeatPrecision
        height: contentView.rowHeight
    }
}
