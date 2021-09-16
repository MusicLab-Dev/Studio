import QtQuick 2.15

import "../Common"

import AudioAPI 1.0
import PartitionModel 1.0
import ActionsManager 1.0
import ClipboardManager 1.0

PlacementArea {
    function addTarget(targetBeatRange, targetKey) {
        if (onTheFlyKey !== -1 && targetKey !== onTheFlyKey)
            removeOnTheFly()
        var note = AudioAPI.note(targetBeatRange, targetKey, AudioAPI.velocityMax, 0)
        var action = undefined
        if (isInMoveMode) {
            action = actionsManager.makeActionMoveNotes(sequencerView.partition, moveCache, [note])
            moveCache = []
        } else
            action = actionsManager.makeActionAddNotes(sequencerView.partition, [note])
        actionsManager.push(action)
        return sequencerView.partition.add(note)
    }

    function removeTarget(targetIndex) {
        var note = sequencerView.partition.getNote(targetIndex)
        if (isInMoveMode)
            moveCache = [note]
        else
            actionsManager.push(actionsManager.makeActionRemoveNotes(sequencerView.partition, [note]))
        return sequencerView.partition.remove(targetIndex)
    }

    function findTarget(targetBeatPrecision, targetKey) {
        return sequencerView.partition.find(targetKey, targetBeatPrecision)
    }

    function findExactTarget(target) {
        return sequencerView.partition.findExact(target)
    }

    function findOverlapTarget(targetBeatRange, targetKey) {
        return sequencerView.partition.findOverlap(targetKey, targetBeatRange)
    }

    function getTargetBeatRange(targetIndex) {
        return sequencerView.partition.getNote(targetIndex).range
    }

    function getTargetKey(targetIndex) {
        return sequencerView.partition.getNote(targetIndex).key
    }

    function constructTarget(targetRange, targetKey) {
        return AudioAPI.note(targetRange, targetKey, AudioAPI.velocityMax, 0)
    }

    function addTargets(targets) {
        var action = undefined
        if (isInMoveMode) {
            action = actionsManager.makeActionMoveNotes(sequencerView.partition, moveCache, targets)
            moveCache = []
        } else
            action = actionsManager.makeActionAddNotes(sequencerView.partition, targets)
        actionsManager.push(action)
        return sequencerView.partition.addRange(targets)
    }

    function removeTargets(targets) {
        var notes = sequencerView.partition.getNotes(targets)
        if (isInMoveMode) {
            moveCache = notes
        } else {
            actionsManager.push(actionsManager.makeActionRemoveNotes(
                sequencerView.partition,
                notes
            ))
        }
        return sequencerView.partition.removeRange(targets)
    }

    function selectTargets(targetBeatRange, targetKeyFrom, targetKeyTo) {
        return sequencerView.partition.select(targetBeatRange, targetKeyFrom, targetKeyTo)
    }


    // On the fly
    function addOnTheFly(targetKey) {
        if (onTheFlyKey !== -1 && onTheFlyKey !== targetKey)
            removeOnTheFly()
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
    function removeOnTheFly() {
        sequencerView.node.partitions.addOnTheFly(
            AudioAPI.noteEvent(
                NoteEvent.Off,
                onTheFlyKey,
                0,
                0
            ),
            sequencerView.node,
            sequencerView.partitionIndex
        )
        onTheFlyKey = -1
    }

    readonly property PartitionModel partition: sequencerView.partition
    property int onTheFlyKey: -1
    property var moveCache: []

    id: placementArea
    enabled: contentView.partition !== null
    keyOffset: pianoView.keyOffset
    keyCount: pianoView.keys
    color: themeManager.getColorFromChain(previewKey)
    accentColor: Qt.lighter(color, 1.6)

    onCopyTarget: {
        // var instance = nodeInstances.instances.getInstance(targetIndex)
        // contentView.selectPartition(
        //     nodeDelegate.node,
        //     instance.partitionIndex
        // )
    }

    onAttachTargetPreview: addOnTheFly(previewKey)
    onMoveTargetPreview: {
        if (offsetKey !== 0)
            addOnTheFly(previewKey)
    }
    onDetachTargetPreview: removeOnTheFly()

    onBrushInserted: addOnTheFly(insertedKey)
    onBrushEnded: removeOnTheFly()


    Connections {
        target: partition
        enabled: placementArea.selectionInsertCache !== null

        function onNotesChanged() {
            placementArea.retreiveInsertedSelection()
        }
    }

    Connections {
        target: eventDispatcher
        enabled: sequencerView.moduleIndex === modulesView.selectedModule

        function onCopy(pressed) {
            if (!pressed || selectionListModel == null)
                return
            var notes = partition.getNotes(selectionListModel)
            clipboardManager.state = ClipboardManager.State.Note
            clipboardManager.count = notes.length
            clipboardManager.copy(clipboardManager.notesToJson(notes))
        }

        function onPaste(pressed) {
            if (!pressed)
                return
            var notes = clipboardManager.jsonToNotes(clipboardManager.paste())
            var analysis = partition.getNotesAnalysis(notes)
            placementArea.selectionInsertCache = notes
            while (partition.hasOverlap(analysis)) {
                for (var i = 0; i < notes.length; i++)
                    notes[i].add(analysis.distance)
                analysis.from += analysis.distance
                analysis.to += analysis.distance
            }
            partition.addRange(notes)
            actionsManager.push(actionsManager.makeActionAddNotes(partition, notes))
        }

        function onCut(pressed) {
            if (!pressed || selectionListModel == null)
                return
            var notes = partition.getNotes(selectionListModel)
            clipboardManager.state = ClipboardManager.State.Note
            clipboardManager.count = notes.length
            clipboardManager.copy(clipboardManager.notesToJson(notes))
            partition.removeRange(selectionListModel)
            actionsManager.push(actionsManager.makeActionRemoveNotes(partition, notes))
            resetSelection()
        }

        function onErase(pressed) {
            if (!pressed || selectionListModel == null)
                return
            var notes = partition.getNotes(selectionListModel)
            partition.removeRange(selectionListModel)
            actionsManager.push(actionsManager.makeActionRemoveNotes(partition, notes))
            resetSelection()
        }
   }
}
