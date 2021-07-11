import QtQuick 2.15

import "../Common"

import AudioAPI 1.0
import PartitionModel 1.0

PlacementArea {
    function addTarget(targetBeatRange, targetKey) {
        removeOnTheFly(onTheFlyKey)
        return sequencerView.partition.add(AudioAPI.note(targetBeatRange, targetKey, AudioAPI.velocityMax, 0))
    }

    function removeTarget(targetIndex) {
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
        return sequencerView.partition.addRange(targets)
    }

    function removeTargets(targets) {
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
}