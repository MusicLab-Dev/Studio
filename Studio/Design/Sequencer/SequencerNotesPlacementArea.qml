import QtQuick 2.15

import "../Common"

import AudioAPI 1.0
import PartitionModel 1.0
import ActionsManager 1.0

PlacementArea {

    property var cacheMove: []

    function addTarget(targetBeatRange, targetKey) {
        if (onTheFlyKey !== -1 && targetKey !== onTheFlyKey)
            removeOnTheFly(onTheFlyKey)
        if (mode === PlacementArea.Mode.Move || mode === PlacementArea.Mode.ResizeRight) {
            var cacheNote = cacheMove[0]
            actionsManager.push(ActionsManager.MoveNotes, actionsManager.makeActionMoveNotes(
                                    partition, [[cacheNote[0], targetBeatRange.from, cacheNote[1], targetBeatRange.to, cacheNote[2], targetKey, cacheNote[3], AudioAPI.velocityMax, cacheNote[4], 0]]))
        } else {
            actionsManager.push(ActionsManager.AddNotes, actionsManager.makeActionAddNotes(
                                    partition, [[targetBeatRange.from, targetBeatRange.to, targetKey, AudioAPI.velocityMax, 0]]))
        }
        console.debug(targetKey)
        return sequencerView.partition.add(AudioAPI.note(targetBeatRange, targetKey, AudioAPI.velocityMax, 0))
    }

    function removeTarget(targetIndex) {
        var note = sequencerView.partition.getNote(targetIndex)
        if (mode === PlacementArea.Mode.Move || mode === PlacementArea.Mode.ResizeRight) {
            cacheMove = []
            cacheMove.push([note.range.from, note.range.to, note.key, note.velocity, note.tuning])
        } else {
            actionsManager.push(ActionsManager.RemoveNotes, actionsManager.makeActionRemoveNotes(
                                    partition, [[note.range.from, note.range.to, note.key, note.velocity, note.tuning]]))
        }
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
        var notes = []
        if (mode === PlacementArea.Mode.Move || mode === PlacementArea.Mode.ResizeRight) {
            for (var i = 0; i < targets.length; i++) {
                var note = targets[i]
                notes.push([cacheMove[0], note.range.from, cacheMove[1], note.range.to, cacheMove[2], note.key, cacheMove[3], note.velocity, cacheMove[4], note.tuning])
            }
            actionsManager.push(ActionsManager.MoveNotes, actionsManager.makeActionMoveNotes(partition, notes))
        } else {
            for (i = 0; i < targets.length; i++) {
                note = targets[i]
                notes.push([note.range.from, note.range.to, note.key, note.velocity, note.tuning])
            }
            actionsManager.push(ActionsManager.AddNotes, actionsManager.makeActionAddNotes(
                                    partition, notes))
        }

        return sequencerView.partition.addRange(targets)
    }

    function removeTargets(targets) {
        if (mode === PlacementArea.Mode.Move || mode === PlacementArea.Mode.ResizeRight) {
            cacheMove = []
            for (var i = 0; i < targets.length; i++) {
                var note = partition.getNote(targets[i])
                cacheMove.push([note.range.from, note.range.to, note.key, note.velocity, note.tuning])
            }
        } else {
            var notes = []
            for (i = 0; i < targets.length; i++) {
                note = partition.getNote(targets[i])
                notes.push([note.range.from, note.range.to, note.key, note.velocity, note.tuning])
            }
            actionsManager.push(ActionsManager.RemoveNotes, actionsManager.makeActionRemoveNotes(
                                    partition, notes))
        }

        return sequencerView.partition.removeRange(targets)
    }

    function selectTargets(targetBeatRange, targetKeyFrom, targetKeyTo) {
        return sequencerView.partition.select(targetBeatRange, targetKeyFrom, targetKeyTo)
    }


    // On the fly
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

    readonly property PartitionModel partition: sequencerView.partition
    property int onTheFlyKey: -1

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

    onDetachTargetPreview: removeOnTheFly(onTheFlyKey)

    Connections {
        target: partition
        enabled: placementArea.selectionInsertCache !== null

        function onNotesChanged() {
            placementArea.retreiveInsertedSelection()
        }
    }

    Connections {
            target: eventDispatcher
            enabled: moduleIndex === modulesView.selectedModule

            function onCopy(pressed) {
                if (!pressed || selectionListModel == null)
                    return
                var list = []
                for (var i = 0; i < selectionListModel.length; i++)
                    list.push(partition.getNote(selectionListModel[i]))
                clipboardManager.copy(clipboardManager.transformNotesInJson(list))
                resetSelection()
            }

            function onPaste(pressed) {
                if (!pressed)
                    return
                var notes = clipboardManager.transformJsonInNotes(clipboardManager.paste())
                placementArea.selectionInsertCache = notes
                partition.addRange(notes)
                actionsManager.push(ActionsManager.AddNotes, actionsManager.makeActionAddRealNotes(partition, notes))
            }

            function onCut(pressed) {
                if (!pressed || selectionListModel == null)
                    return
                var list = []
                for (var i = 0; i < selectionListModel.length; i++)
                    list.push(partition.getNote(selectionListModel[i]))
                clipboardManager.copy(clipboardManager.transformNotesInJson(list))
                partition.removeRange(selectionListModel)
                resetSelection()
            }

            function onErase(pressed) {
                if (!pressed)
                    return
                //actionsManager.push(ActionsManager.RemoveNotes, actionsManager.makeActionRemoveNotes(partition, selectionListModel))
                partition.removeRange(selectionListModel)
                resetSelection()
            }
   }
}
