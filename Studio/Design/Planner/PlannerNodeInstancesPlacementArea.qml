
import QtQuick 2.15

import "../Common"

import AudioAPI 1.0
import PartitionPreview 1.0
import ActionsManager 1.0

PlacementArea {
    property var cacheMove: []

    function addTarget(targetBeatRange, targetKey) {
        if (mode === PlacementArea.Mode.Move || mode === PlacementArea.Mode.ResizeRight) {
            var cache = cacheMove[0]
            actionsManager.push(ActionsManager.MovePartitions, actionsManager.makeActionMovePartitions(
                                    nodeInstances.partitions, [[cache[0], contentView.selectedPartitionIndex, cache[1], 0, cache[2], targetBeatRange.from, cache[3], targetBeatRange.to]]))
        } else {
            actionsManager.push(ActionsManager.AddPartitions, actionsManager.makeActionAddPartitions(
                                    nodeInstances.partitions, [[contentView.selectedPartitionIndex, 0, targetBeatRange.from, targetBeatRange.to]]))
        }

        return nodeDelegate.node == contentView.selectedPartitionNode && nodeInstances.instances.add(
            AudioAPI.partitionInstance(contentView.selectedPartitionIndex, 0, targetBeatRange)
        )
    }

    function removeTarget(targetIndex) {
        var partition = nodeInstances.instances.getInstance(targetIndex)
        if (mode === PlacementArea.Mode.Move || mode === PlacementArea.Mode.ResizeRight) {
            cacheMove = []
            cacheMove.push([partition.partitionIndex, partition.offset, partition.range.from, partition.range.to])
        } else {
            actionsManager.push(ActionsManager.RemovePartitions, actionsManager.makeActionRemovePartitions(
                                nodeInstances.partitions, [partition]))
        }
        return nodeInstances.instances.remove(targetIndex)
    }

    function findTarget(targetBeatPrecision, targetKey) {
        return nodeInstances.instances.find(targetBeatPrecision)
    }

    function findExactTarget(target) {
        return nodeInstances.instances.findExact(target)
    }

    function findOverlapTarget(targetBeatRange, targetKey) {
        return nodeInstances.instances.findOverlap(targetBeatRange)
    }

    function getTargetBeatRange(targetIndex) {
        return nodeInstances.instances.getInstance(targetIndex).range
    }

    function getTargetKey(targetIndex) { return 0 }

    function constructTarget(targetRange, targetKey) {
        return AudioAPI.partitionInstance(0, 0, targetRange)
    }

    function addTargets(targets) {
        var instances = []
        if (mode === PlacementArea.Mode.Move || mode === PlacementArea.Mode.ResizeRight) {
            for (var i = 0; i < cacheMove.length; i++) {
                var cache = cacheMove[i]
                instances.push([cache[0], contentView.selectedPartitionIndex, cache[1], 0, cache[2], targetBeatRange.from, cache[3], targetBeatRange.to])
            }
            actionsManager.push(ActionsManager.MovePartitions, actionsManager.makeActionMovePartitions(
                                    nodeInstances.partitions, instances))
        } else {
            for (i = 0; i < cacheMove.length; i++) {
                cache = cacheMove[i]
                instances.push([cache[0], cache[1], cache[2], cache[3]])
            }
            actionsManager.push(ActionsManager.AddPartitions, actionsManager.makeActionAddPartitions(
                                    nodeInstances.partitions, instances))
        }
        return nodeInstances.instances.addRange(targets)
    }

    function removeTargets(targets) {
        if (mode === PlacementArea.Mode.Move || mode === PlacementArea.Mode.ResizeRight) {
            cacheMove = []
            for (var i = 0; targets.length; i++) {
                var instance = nodeInstances.instances.getInstance(targets[i])
                cacheMove.push([instance.partitionIndex, instance.offset, instance.range.from, instance.range.to])
            }
        } else {
            var instances = []
            for (i = 0; targets.length; i++) {
                instance = nodeInstances.instances.getInstance(targets[i])
                instances.push([instance.partitionIndex, instance.offset, instance.range.from, instance.range.to])
            }
            actionsManager.push(ActionsManager.RemovePartitions, actionsManager.makeActionRemovePartitions(
                                nodeInstances.partitions, [instances]))
        }
        return nodeInstances.instances.removeRange(targets)
    }

    function selectTargets(targetBeatRange, targetKeyFrom, targetKeyTo) {
        return nodeInstances.instances.select(targetBeatRange)
    }

    // Preview extension
    property var previewInstanceOffset: 0

    id: placementArea
    allowInsert: contentView.selectedPartition !== null
    color: nodeDelegate.color
    accentColor: nodeDelegate.accentColor

    onCopyTarget: {
        var instance = nodeInstances.instances.getInstance(targetIndex)
        contentView.selectPartition(
            nodeDelegate.node,
            instance.partitionIndex
        )
    }

    Connections {
        target: nodeInstances.instances
        enabled: placementArea.selectionInsertCache !== null

        function onInstancesChanged() {
            placementArea.retreiveInsertedSelection()
        }
    }

    PartitionPreview {
        id: placementPartitionPreview
        anchors.fill: previewRectangle
        anchors.margins: previewRectangle.border.width
        offset: placementArea.previewInstanceOffset
        range: placementArea.previewRange
        target: previewRectangle.visible ? contentView.selectedPartition : null
    }
}
