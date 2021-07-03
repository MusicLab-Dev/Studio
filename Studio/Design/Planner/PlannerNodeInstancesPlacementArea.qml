import QtQuick 2.15

import "../Common"

import AudioAPI 1.0
import PartitionPreview 1.0

PlacementArea {
    function addTarget(targetBeatRange, targetKey) {
        return nodeDelegate.node == contentView.selectedPartitionNode && nodeInstances.instances.add(
            AudioAPI.partitionInstance(contentView.selectedPartitionIndex, 0, targetBeatRange)
        )
    }

    function removeTarget(targetIndex) {
        return nodeInstances.instances.remove(targetIndex)
    }

    function findTarget(targetBeatPrecision) {
        return nodeInstances.instances.find(targetBeatPrecision)
    }

    function getTargetBeatRange(targetIndex) {
        return nodeInstances.instances.getInstance(targetIndex).range
    }

    function getTargetKey(targetIndex) { return 0 }

    function constructTarget(targetRange, targetKey) {
        return AudioAPI.partitionInstance(0, 0, targetRange)
    }

    function addTargets(targets) {
        return nodeInstances.instances.addRange(targets)
    }

    function removeTargets(targets) {
        return nodeInstances.instances.removeRange(targets)
    }

    function selectTargets(targetBeatRange, targetKeyFrom, targetKeyTo) {
        return nodeInstances.instances.select(targetBeatRange)
    }

    // Preview extension
    property var previewInstanceOffset: 0

    id: placementArea
    enabled: contentView.selectedPartition !== null

    PartitionPreview {
        id: placementPartitionPreview
        anchors.fill: previewRectangle
        anchors.margins: previewRectangle.border.width
        offset: placementArea.previewInstanceOffset
        range: placementArea.previewRange
        target: previewRectangle.visible ? contentView.selectedPartition : null
    }
}