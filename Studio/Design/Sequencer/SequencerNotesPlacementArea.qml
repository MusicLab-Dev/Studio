import QtQuick 2.15
import QtQuick.Controls 2.15

import Scheduler 1.0
import PartitionModel 1.0
import AudioAPI 1.0
import ActionsManager 1.0

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
        BrushRight,
        Select,
        SelectRemove,
        SelectMove,
        SelectLeftResize,
        SelectRightResize
    }

    enum Inversion {
        None,
        Left,
        Right
    }

    property PartitionModel partition: null
    property int mode: SequencerNotesPlacementArea.Mode.None
    property int onTheFlyKey: -1

    // Brush
    property int brushKey: 0
    property int brushBegin: 0
    property int brushEnd: 0
    property int brushStep: 0
    property int brushWidth: 0

    // Selection
    property real selectionBeatPrecisionFrom: 0
    property real selectionBeatPrecisionTo: 0
    property real selectionKeyFrom: 0
    property real selectionKeyTo: 0
    property var selectionListModel: null
    property var selectionMoveBeatPrecisionOffset: 0
    property var selectionMoveKeyOffset: 0
    property var selectionMoveLeftOffset: 0
    property var selectionMoveTopOffset: 0
    property var selectionMoveBottomOffset: 0

    property var oldNoteFrom
    property var oldNoteTo
    property var oldNoteKey
    property var oldNoteVelocity
    property var oldNoteTuning
    property bool isMoving: false

    function resetBrush() {
        brushKey = 0
        brushBegin = 0
        brushEnd = 0
        brushStep = 0
        brushWidth = 0
    }

    function resetSelection() {
        selectionBeatPrecisionFrom = 0
        selectionBeatPrecisionTo = 0
        selectionKeyFrom = 0
        selectionKeyTo = 0
        selectionListModel = null
        selectionMoveBeatPrecisionOffset = 0
        selectionMoveKeyOffset = 0
        selectionMoveLeftOffset = 0
        selectionMoveTopOffset = 0
        selectionMoveBottomOffset = 0
    }

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

    function getScopedMouseBeatPrecision() {
        var realMouseBeatPrecision = Math.floor((mouseX - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
        if (realMouseBeatPrecision < selectionMoveLeftOffset)
            realMouseBeatPrecision = selectionMoveLeftOffset
        return realMouseBeatPrecision
    }

    function getScopedBeatPrecision(realMouseBeatPrecision) {
        var noteBeatPrecision = realMouseBeatPrecision - contentView.placementBeatPrecisionMouseOffset
        if (noteBeatPrecision < selectionMoveLeftOffset)
            noteBeatPrecision = selectionMoveLeftOffset
        return noteBeatPrecision
    }

    function getScopedMouseKey() {
        var mouseKey = pianoView.keyOffset + Math.floor((height - mouseY) / contentView.rowHeight)
        if (mouseKey < pianoView.keyMin + selectionMoveBottomOffset)
            mouseKey = pianoView.keyMin + selectionMoveBottomOffset
        else if (mouseKey > pianoView.keyMax - selectionMoveTopOffset)
            mouseKey = pianoView.keyMax - selectionMoveTopOffset
        return mouseKey
    }

    id: contentPlacementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    clip: true

    onPressedChanged: forceActiveFocus()

    onPressed: {
        var isSelection = sequencerView.editMode === SequencerView.EditMode.Select || mouse.modifiers & Qt.ControlModifier
        var realMouseBeatPrecision = Math.floor((mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
        var mouseKey = pianoView.keyOffset + Math.floor((height - mouse.y) / contentView.rowHeight)
        var noteIndex = partition.find(mouseKey, realMouseBeatPrecision)

        resetBrush()
        // Right click on note -> delete
        if (mouse.buttons & Qt.RightButton) {
            resetSelection()
            mode = SequencerNotesPlacementArea.Mode.Remove
            if (isSelection) {
                mode = SequencerNotesPlacementArea.Mode.SelectRemove
                selectionBeatPrecisionFrom = realMouseBeatPrecision
                selectionBeatPrecisionTo = realMouseBeatPrecision
                selectionKeyFrom = mouseKey
                selectionKeyTo = mouseKey
            } else if (noteIndex !== -1) {
                var note = partition.getNote(noteIndex)
                actionsManager.push(ActionsManager.Action.RemoveNote,
                                    actionsManager.makeActionRemoveNote(partition, 0, 0, note.range.from, note.range.to, note.key, note.velocity, note.tuning))
                partition.remove(noteIndex)
            }
            return
        }

        var mouseBeatPrecision = realMouseBeatPrecision
        if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % AudioAPI.beatPrecision)
        else if (contentView.placementBeatPrecisionScale !== 0)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)

        // Left click not on note -> insert
        if (noteIndex === -1) {
            resetSelection()
            // Select mode, start selection
            if (isSelection) {
                mode = SequencerNotesPlacementArea.Mode.Select
                selectionBeatPrecisionFrom = realMouseBeatPrecision
                selectionBeatPrecisionTo = realMouseBeatPrecision
                selectionKeyFrom = mouseKey
                selectionKeyTo = mouseKey
                return
            }
            if (contentView.placementBeatPrecisionLastWidth === 0)
                contentView.placementBeatPrecisionLastWidth = contentView.placementBeatPrecisionDefaultWidth
            // Brush mode, insert note directly
            if (sequencerView.editMode === SequencerView.EditMode.Brush) {
                mode = SequencerNotesPlacementArea.Mode.Brush
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

                actionsManager.push(ActionsManager.Action.AddNote,
                                    actionsManager.makeActionAddNote(partition, 0, 0, brushBegin, brushBegin + contentView.placementBeatPrecisionLastWidth, brushKey, AudioAPI.velocityMax, 0))
            // Move mode, attach preview
            } else {
                // Attach the preview
                contentView.placementRectangle.attach(contentPlacementArea, themeManager.getColorFromChain(mouseKey))
                mode = SequencerNotesPlacementArea.Mode.Move
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
            var isPartOfSelection = selectionListModel !== null && selectionListModel.indexOf(noteIndex) !== -1
            contentView.placementBeatPrecisionLastWidth = noteWidthBeatPrecision
            if ((realMouseBeatPrecision - beatPrecisionRange.from) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = isPartOfSelection ? SequencerNotesPlacementArea.Mode.SelectLeftResize : SequencerNotesPlacementArea.Mode.LeftResize
            else if ((beatPrecisionRange.to - realMouseBeatPrecision) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = isPartOfSelection ? SequencerNotesPlacementArea.Mode.SelectRightResize : SequencerNotesPlacementArea.Mode.RightResize
            else
                mode = isPartOfSelection ? SequencerNotesPlacementArea.Mode.SelectMove : SequencerNotesPlacementArea.Mode.Move
            if (mode < SequencerNotesPlacementArea.Mode.Select) {
                resetSelection()
                partition.remove(noteIndex)
            } else {
                partition.removeRange(selectionListModel)
                var firstNote = selectionList.itemAt(0).note
                selectionMoveLeftOffset = firstNote.range.from
                selectionMoveTopOffset = firstNote.key
                selectionMoveBottomOffset = firstNote.key
                for (var i = 1; i < selectionList.count; ++i) {
                    var item = selectionList.itemAt(i)
                    var note = item.note
                    selectionMoveLeftOffset = Math.min(selectionMoveLeftOffset, note.range.from)
                    selectionMoveTopOffset = Math.max(selectionMoveTopOffset, note.key)
                    selectionMoveBottomOffset =  Math.min(selectionMoveBottomOffset, note.key)
                }
                selectionMoveLeftOffset = beatPrecisionRange.from - selectionMoveLeftOffset
                selectionMoveTopOffset = selectionMoveTopOffset - mouseKey
                selectionMoveBottomOffset = mouseKey - selectionMoveBottomOffset
            }
            // Attach the preview
            contentView.placementRectangle.attach(contentPlacementArea, themeManager.getColorFromChain(mouseKey))
            contentView.placementBeatPrecisionFrom = beatPrecisionRange.from
            contentView.placementBeatPrecisionTo = beatPrecisionRange.to
            contentView.placementBeatPrecisionMouseOffset = mouseBeatPrecision - beatPrecisionRange.from
            contentView.placementKey = mouseKey

            isMoving = true
            oldNoteFrom = contentView.placementBeatPrecisionFrom
            oldNoteTo = contentView.placementBeatPrecisionTo
            oldNoteKey = contentView.placementKey
            oldNoteVelocity = AudioAPI.velocityMax
            oldNoteTuning = 0

        }

        // Add an on the fly note if the sequencer isn't playing
        if (!sequencerView.player.isPlaying)
            addOnTheFly(mouseKey)
    }

    onPositionChanged: {
        var realMouseBeatPrecision = getScopedMouseBeatPrecision()
        var mouseKey = getScopedMouseKey()
        switch (mode) {
        case SequencerNotesPlacementArea.Mode.Remove:
            var noteIndex = partition.find(mouseKey, realMouseBeatPrecision)
            if (noteIndex !== -1)
                partition.remove(noteIndex)
            break
        case SequencerNotesPlacementArea.Mode.Move:
        case SequencerNotesPlacementArea.Mode.SelectMove:
            var noteBeatPrecision = getScopedBeatPrecision(realMouseBeatPrecision)
            var oldBeat = contentView.placementBeatPrecisionFrom
            var oldKey = contentView.placementKey
            if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
                noteBeatPrecision = noteBeatPrecision - (noteBeatPrecision % AudioAPI.beatPrecision)
            else if (contentView.placementBeatPrecisionScale !== 0)
                noteBeatPrecision = noteBeatPrecision - (noteBeatPrecision % contentView.placementBeatPrecisionScale)
            contentView.placementBeatPrecisionTo = noteBeatPrecision + contentView.placementBeatPrecisionWidth
            contentView.placementBeatPrecisionFrom = noteBeatPrecision
            if (contentView.placementKey !== mouseKey) {
                contentView.placementRectangle.targetColor = themeManager.getColorFromChain(mouseKey)
                if (!sequencerView.player.isPlaying)
                    addOnTheFly(mouseKey)
                contentView.placementKey = mouseKey
            }
            if (mode === SequencerNotesPlacementArea.Mode.SelectMove) {
                selectionMoveBeatPrecisionOffset += (contentView.placementBeatPrecisionFrom - oldBeat)
                selectionMoveKeyOffset += contentView.placementKey - oldKey
            }
            break
        case SequencerNotesPlacementArea.Mode.LeftResize:
        case SequencerNotesPlacementArea.Mode.SelectLeftResize:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale) + (contentView.placementBeatPrecisionFrom % contentView.placementBeatPrecisionScale)
            var oldFrom = contentView.placementBeatPrecisionFrom
            if (contentView.placementBeatPrecisionTo > mouseBeatPrecision)
                contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            else
                contentView.placementBeatPrecisionFrom = contentView.placementBeatPrecisionTo - contentView.placementBeatPrecisionScale
            if (mode === SequencerNotesPlacementArea.Mode.SelectLeftResize && contentView.placementBeatPrecisionFrom != oldFrom)
                selectionList.resizeLeft(contentView.placementBeatPrecisionFrom - oldFrom)
            break
        case SequencerNotesPlacementArea.Mode.RightResize:
        case SequencerNotesPlacementArea.Mode.SelectRightResize:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision + (contentView.placementBeatPrecisionScale - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)) + (contentView.placementBeatPrecisionTo % contentView.placementBeatPrecisionScale)
            var oldTo = contentView.placementBeatPrecisionTo
            if (contentView.placementBeatPrecisionFrom < mouseBeatPrecision)
                contentView.placementBeatPrecisionTo = mouseBeatPrecision
            else
                contentView.placementBeatPrecisionTo = contentView.placementBeatPrecisionFrom + contentView.placementBeatPrecisionScale
            if (mode === SequencerNotesPlacementArea.Mode.SelectRightResize && contentView.placementBeatPrecisionTo != oldTo)
                selectionList.resizeRight(contentView.placementBeatPrecisionTo - oldTo)
            break
        case SequencerNotesPlacementArea.Mode.Brush:
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
            if (brushBegin >= 0 && partition.findOverlap(brushKey, AudioAPI.beatRange(brushBegin + 1, brushBegin + contentView.placementBeatPrecisionLastWidth - 1)) === -1) {
                if (!sequencerView.player.isPlaying)
                    addOnTheFly(brushKey)
                var end = brushBegin + contentView.placementBeatPrecisionLastWidth
                partition.add(
                    AudioAPI.note(
                        AudioAPI.beatRange(brushBegin, end),
                        brushKey,
                        AudioAPI.velocityMax,
                        0
                    )
                )
                actionsManager.push(ActionsManager.Action.AddNote,
                                    actionsManager.makeActionAddNote(partition, 0, 0, brushBegin, end, brushKey, AudioAPI.velocityMax, 0))
            }
            break
        case SequencerNotesPlacementArea.Mode.Select:
        case SequencerNotesPlacementArea.Mode.SelectRemove:
            selectionBeatPrecisionTo = realMouseBeatPrecision
            selectionKeyTo = mouseKey
            break
        default:
            break
        }
    }

    onReleased: {
        console.debug(mode)
        switch (mode) {
        case SequencerNotesPlacementArea.Mode.Move:
        case SequencerNotesPlacementArea.Mode.LeftResize:
        case SequencerNotesPlacementArea.Mode.RightResize:
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

            if (isMoving)
                actionsManager.push(ActionsManager.Action.MoveNote,
                                actionsManager.makeActionMoveNote(partition, 0, 0,
                                                                  oldNoteFrom, contentView.placementBeatPrecisionFrom,
                                                                  oldNoteTo, contentView.placementBeatPrecisionTo,
                                                                  oldNoteKey, contentView.placementKey,
                                                                  oldNoteVelocity, AudioAPI.velocityMax,
                                                                  oldNoteTuning, 0))
            else
                actionsManager.push(ActionsManager.Action.AddNote,
                                actionsManager.makeActionAddNote(partition, 0, 0, contentView.placementBeatPrecisionFrom, contentView.placementBeatPrecisionTo, contentView.placementKey, AudioAPI.velocityMax, 0))
            isMoving = false
            break
        case SequencerNotesPlacementArea.Mode.Select:
            // Select notes
            var list = partition.select(
                AudioAPI.beatRange(
                    Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo),
                    Math.max(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
                ),
                Math.min(selectionKeyFrom, selectionKeyTo),
                Math.max(selectionKeyFrom, selectionKeyTo)
            )
            selectionListModel = list
            break
        case SequencerNotesPlacementArea.Mode.SelectRemove:
            // Select notes
            var list = partition.select(
                AudioAPI.beatRange(
                    Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo),
                    Math.max(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
                ),
                Math.min(selectionKeyFrom, selectionKeyTo),
                Math.max(selectionKeyFrom, selectionKeyTo)
            )
            partition.removeRange(list)
            break
        case SequencerNotesPlacementArea.Mode.SelectMove:
        case SequencerNotesPlacementArea.Mode.SelectLeftResize:
        case SequencerNotesPlacementArea.Mode.SelectRightResize:
            partition.addRange(selectionList.toList())
            selectionMoveBeatPrecisionOffset = 0
            selectionMoveKeyOffset = 0
            break
        default:
            break
        }
        contentView.placementRectangle.detach()
        mode = SequencerNotesPlacementArea.Mode.None
        if (onTheFlyKey !== -1)
            removeOnTheFly(onTheFlyKey)
    }

    Rectangle {
        color: "transparent"
        border.color: Qt.darker(themeManager.getColorFromChain(brushKey), 1.5)
        border.width: 2
        visible: mode === SequencerNotesPlacementArea.Mode.Brush
        x: contentView.xOffset + brushBegin * contentView.pixelsPerBeatPrecision
        y: parent.height - (brushKey - pianoView.keyOffset + 1) * contentView.rowHeight
        width: (brushEnd - brushBegin) * contentView.pixelsPerBeatPrecision
        height: contentView.rowHeight
    }

    Repeater {
        function toList() {
            var list = []
            for (var i = 0; i < count; ++i) {
                list[i] = getMoved(itemAt(i))
            }
            return list
        }

        function getMoved(item) {
            var copy = item.note
            var rangeCopy = copy.range
            if (selectionMoveBeatPrecisionOffset < 0 && -selectionMoveBeatPrecisionOffset > rangeCopy.from) {
                rangeCopy.to = rangeCopy.to - rangeCopy.from
                rangeCopy.from = 0
            } else {
                rangeCopy.from += selectionMoveBeatPrecisionOffset
                rangeCopy.to += selectionMoveBeatPrecisionOffset
            }
            copy.range = rangeCopy
            copy.key += selectionMoveKeyOffset
            item.note = copy
            return copy
        }

        function resizeLeft(offset) {
            for (var i = 0; i < count; ++i) {
                var item = itemAt(i)
                var note = item.note
                var range = note.range
                if (range.from + offset < range.to)
                    range.from += offset
                if (range.from < 0)
                    range.from = 0;
                note.range = range
                item.note = note
            }
        }

        function resizeRight(offset) {
            for (var i = 0; i < count; ++i) {
                var item = itemAt(i)
                var note = item.note
                var range = note.range
                if (range.to + offset > range.from)
                    range.to += offset
                note.range = range
                item.note = note
            }
        }

        id: selectionList
        model: selectionListModel

        delegate: Rectangle {
            property var note: partition.getNote(modelData)

            x: contentView.xOffset + (selectionMoveBeatPrecisionOffset + note.range.from) * contentView.pixelsPerBeatPrecision
            y: parent.height - (selectionMoveKeyOffset + note.key - pianoView.keyOffset + 1) * contentView.rowHeight
            width: (note.range.to - note.range.from) * contentView.pixelsPerBeatPrecision
            height: contentView.rowHeight
            color: "white"
            opacity: 0.5
        }
    }

    Rectangle {
        id: selectionOverlay
        visible: mode === SequencerNotesPlacementArea.Mode.Select || mode === SequencerNotesPlacementArea.Mode.SelectRemove
        x: contentView.xOffset + Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo) * contentView.pixelsPerBeatPrecision
        y: parent.height - (Math.max(selectionKeyFrom, selectionKeyTo) - pianoView.keyOffset + 1) * contentView.rowHeight
        width: Math.abs(selectionBeatPrecisionTo - selectionBeatPrecisionFrom) * contentView.pixelsPerBeatPrecision
        height: (Math.abs(selectionKeyTo - selectionKeyFrom) + 1) * contentView.rowHeight
        color: "grey"
        opacity: 0.5
        border.color: "white"
        border.width: 1
    }
}
