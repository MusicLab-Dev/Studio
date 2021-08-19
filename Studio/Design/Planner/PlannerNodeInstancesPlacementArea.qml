
import QtQuick 2.15

import "../Common"

import AudioAPI 1.0
import PartitionPreview 1.0
import ActionsManager 1.0

PlacementArea {
    function addTarget(targetBeatRange, targetKey) {
        var partitionInstance = AudioAPI.partitionInstance(contentView.selectedPartitionIndex, 0, targetBeatRange)
        if (!contentView.selectedPartitionNode)
            return false
        else if (nodeDelegate.node != contentView.selectedPartitionNode) {
            instanceCopyPopup.open(
                nodeDelegate.node,
                contentView.selectedPartitionNode,
                contentView.selectedPartition,
                partitionInstance
            )
            return false
        } else {
            var action = undefined
            if (isInMoveMode)
                action = actionsManager.makeActionMovePartitions(nodeInstances.partitions, moveCache, [partitionInstance])
            else
                action = actionsManager.makeActionAddPartitions(nodeInstances.partitions, [partitionInstance])
            actionsManager.push(action)
            return nodeInstances.instances.add(partitionInstance)
        }
    }

    function removeTarget(targetIndex) {
        var partitionInstance = nodeInstances.instances.getInstance(targetIndex)
        if (isInMoveMode)
            moveCache = [partitionInstance]
        else
            actionsManager.push(actionsManager.makeActionRemovePartitions(nodeInstances.partitions, [partitionInstance]))
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
        var action = undefined
        if (isInMoveMode) {
            action = actionsManager.makeActionMovePartitions(nodeInstances.partitions, moveCache, targets)
            moveCache = []
        } else
            action = actionsManager.makeActionAddPartitions(nodeInstances.partitions, targets)
        actionsManager.push(action)
        return nodeInstances.instances.addRange(targets)
    }

    function removeTargets(targets) {
        var instances = nodeInstances.instances.getInstances(targets)
        if (isInMoveMode) {
            moveCache = instances
        } else {
            actionsManager.push(actionsManager.makeActionRemovePartitions(
                nodeInstances.partitions,
                instances
            ))
        }
        return nodeInstances.instances.removeRange(targets)
    }

    function selectTargets(targetBeatRange, targetKeyFrom, targetKeyTo) {
        return nodeInstances.instances.select(targetBeatRange)
    }

    // Preview extension
    property var previewInstanceOffset: 0
    property var moveCache: []

    id: placementArea
    allowInsert: contentView.selectedPartition !== null
    color: nodeDelegate.color
    accentColor: nodeDelegate.accentColor

    onCopyTarget: {
        var instance = nodeInstances.instances.getInstance(targetIndex)
        contentView.selectPartition(nodeDelegate.node, instance.partitionIndex)
    }

    PartitionPreview {
        id: placementPartitionPreview
        anchors.fill: previewRectangle
        anchors.margins: previewRectangle.border.width
        offset: placementArea.previewInstanceOffset
        range: placementArea.previewRange
        target: previewRectangle.visible ? contentView.selectedPartition : null
        visible: previewRectangle.visible
    }

    Connections {
        target: nodeInstances.instances
        enabled: placementArea.selectionInsertCache !== null

        function onInstancesChanged() {
            placementArea.retreiveInsertedSelection()
        }
    }

    Connections {
        target: contentView

        function onResetPlacementAreaSelection() {
            placementArea.resetSelection()
        }
    }

    Connections {
        target: eventDispatcher
        enabled: plannerView.moduleIndex === modulesView.selectedModule

        function onCopy(pressed) {
            if (!pressed || selectionListModel == null)
                return
            var instances = nodeInstances.instances.getInstances(selectionListModel)
            clipboardManager.copy(clipboardManager.partitionInstancesToJson(instances))
        }

        function onPaste(pressed) {
            if (!pressed)
                return
            var instances = clipboardManager.jsonToPartitionInstances(clipboardManager.paste())
            var analysis = nodeInstances.instances.getPartitionInstancesAnalysis(instances)
            placementArea.selectionInsertCache = instances
            while (nodeInstances.instances.hasOverlap(analysis)) {
                for (var i = 0; i < instances.length; i++)
                    instances[i].add(analysis.distance)
                analysis.from += analysis.distance
                analysis.to += analysis.distance
            }
            nodeInstances.instances.addRange(instances)
            actionsManager.push(actionsManager.makeActionAddPartitions(nodeInstances.partitions, instances))
        }

        function onCut(pressed) {
            if (!pressed || selectionListModel == null)
                return
            var instances = nodeInstances.instances.getInstances(selectionListModel)
            clipboardManager.copy(clipboardManager.partitionInstancesToJson(instances))
            nodeInstances.instances.removeRange(selectionListModel)
            actionsManager.push(actionsManager.makeActionRemovePartitions(nodeInstances.partitions, instances))
            resetSelection()
        }

        function onErase(pressed) {
            if (!pressed || selectionListModel == null)
                return
            var instances = nodeInstances.instances.getInstances(selectionListModel)
            nodeInstances.instances.removeRange(selectionListModel)
            actionsManager.push(actionsManager.makeActionRemovePartitions(nodeInstances.instances, instances))
            resetSelection()
        }
   }
}
