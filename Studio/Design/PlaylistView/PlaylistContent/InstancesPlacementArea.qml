import QtQuick 2.15
import QtQuick.Controls 2.15

import Scheduler 1.0
import InstancesModel 1.0
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

    property PartitionModel targetPartition: null
    property InstancesModel instances: null
    property int mode: InstancesPlacementArea.Mode.None

    // Brush
    property int brushBegin: 0
    property int brushEnd: 0
    property int brushStep: 0
    property int brushWidth: 0

    // Selection
    property real selectionBeatPrecisionFrom: 0
    property real selectionBeatPrecisionTo: 0
    property var selectionListModel: null
    property var selectionMoveBeatPrecisionOffset: 0
    property var selectionMoveLeftOffset: 0

    function resetBrush() {
        brushBegin = 0
        brushEnd = 0
        brushStep = 0
        brushWidth = 0
    }

    function resetSelection() {
        selectionBeatPrecisionFrom = 0
        selectionBeatPrecisionTo = 0
        selectionListModel = null
        selectionMoveBeatPrecisionOffset = 0
        selectionMoveLeftOffset = 0
    }


    function getScopedMouseBeatPrecision() {
        var realMouseBeatPrecision = Math.floor((mouseX - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
        if (realMouseBeatPrecision < selectionMoveLeftOffset)
            realMouseBeatPrecision = selectionMoveLeftOffset
        return realMouseBeatPrecision
    }

    function getScopedBeatPrecision(realMouseBeatPrecision) {
        var instanceBeatPrecision = realMouseBeatPrecision - contentView.placementBeatPrecisionMouseOffset
        if (instanceBeatPrecision < selectionMoveLeftOffset)
            instanceBeatPrecision = selectionMoveLeftOffset
        return instanceBeatPrecision
    }

    id: contentPlacementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    clip: true

    onPressedChanged: forceActiveFocus()

    onPressed: {
        var isSelection = playlistView.editMode === PlaylistView.EditMode.Select || mouse.modifiers & Qt.ShiftModifier
        var realMouseBeatPrecision = Math.floor((mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
        var instanceIndex = instances.find(realMouseBeatPrecision)

        resetBrush()
        // Right click on instance -> delete
        if (mouse.buttons & Qt.RightButton) {
            resetSelection()
            mode = InstancesPlacementArea.Mode.Remove
            if (isSelection) {
                mode = InstancesPlacementArea.Mode.SelectRemove
                selectionBeatPrecisionFrom = realMouseBeatPrecision
                selectionBeatPrecisionTo = realMouseBeatPrecision
            } else if (instanceIndex !== -1)
                instances.remove(instanceIndex)
            return
        }

        var mouseBeatPrecision = realMouseBeatPrecision
        if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % AudioAPI.beatPrecision)
        else if (contentView.placementBeatPrecisionScale !== 0)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)

        // Left click not on instance -> insert
        if (instanceIndex === -1) {
            resetSelection()
            // Select mode, start selection
            if (isSelection) {
                mode = InstancesPlacementArea.Mode.Select
                selectionBeatPrecisionFrom = realMouseBeatPrecision
                selectionBeatPrecisionTo = realMouseBeatPrecision
                return
            }
            if (contentView.placementBeatPrecisionLastWidth === 0)
                contentView.placementBeatPrecisionLastWidth = contentView.placementBeatPrecisionDefaultWidth
            // Brush mode, insert instance directly
            if (playlistView.editMode === PlaylistView.EditMode.Brush) {
                mode = InstancesPlacementArea.Mode.Brush
                brushBegin = mouseBeatPrecision
                brushWidth = contentView.placementBeatPrecisionLastWidth + brushStep
                brushEnd = mouseBeatPrecision + brushWidth
                instances.add(
                    AudioAPI.beatRange(
                        brushBegin,
                        brushBegin + contentView.placementBeatPrecisionLastWidth
                    )
                )
            // Move mode, attach preview
            } else {
                // Attach the preview
                if (targetPartition !== null)
                    contentView.placementRectangle.attachPartition(contentPlacementArea, nodeDelegate.node.color, targetPartition)
                else
                    contentView.placementRectangle.attach(contentPlacementArea, nodeDelegate.node.color)
                mode = InstancesPlacementArea.Mode.Move
                contentView.placementBeatPrecisionTo = mouseBeatPrecision + contentView.placementBeatPrecisionLastWidth
                contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            }
        // Left click on instance -> edit
        } else {
            var beatPrecisionRange = instances.getInstance(instanceIndex)
            var instanceWidthBeatPrecision = (beatPrecisionRange.to - beatPrecisionRange.from)
            var instanceWidth = instanceWidthBeatPrecision * contentView.pixelsPerBeatPrecision
            var resizeThreshold = Math.min(instanceWidth * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
            var isPartOfSelection = selectionListModel !== null && selectionListModel.indexOf(instanceIndex) !== -1
            contentView.placementBeatPrecisionLastWidth = instanceWidthBeatPrecision
            if ((realMouseBeatPrecision - beatPrecisionRange.from) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = isPartOfSelection ? InstancesPlacementArea.Mode.SelectLeftResize : InstancesPlacementArea.Mode.LeftResize
            else if ((beatPrecisionRange.to - realMouseBeatPrecision) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = isPartOfSelection ? InstancesPlacementArea.Mode.SelectRightResize : InstancesPlacementArea.Mode.RightResize
            else
                mode = isPartOfSelection ? InstancesPlacementArea.Mode.SelectMove : InstancesPlacementArea.Mode.Move
            if (mode < InstancesPlacementArea.Mode.Select) {
                resetSelection()
                instances.remove(instanceIndex)
            } else {
                instances.removeRange(selectionListModel)
                var firstInstance = selectionList.itemAt(0).instance
                selectionMoveLeftOffset = firstInstance.from
                for (var i = 1; i < selectionList.count; ++i) {
                    var item = selectionList.itemAt(i)
                    var instance = item.instance
                    selectionMoveLeftOffset = Math.min(selectionMoveLeftOffset, instance.from)
                }
                selectionMoveLeftOffset = beatPrecisionRange.from - selectionMoveLeftOffset
            }
            // Attach the preview
            if (targetPartition !== null)
                contentView.placementRectangle.attachPartition(contentPlacementArea, nodeDelegate.node.color, targetPartition)
            else
                contentView.placementRectangle.attach(contentPlacementArea, nodeDelegate.node.color)
            contentView.placementBeatPrecisionFrom = beatPrecisionRange.from
            contentView.placementBeatPrecisionTo = beatPrecisionRange.to
            contentView.placementBeatPrecisionMouseOffset = mouseBeatPrecision - beatPrecisionRange.from
        }
    }

    onPositionChanged: {
        var realMouseBeatPrecision = getScopedMouseBeatPrecision()
        switch (mode) {
        case InstancesPlacementArea.Mode.Remove:
            var instanceIndex = instances.find(realMouseBeatPrecision)
            if (instanceIndex !== -1)
                instances.remove(instanceIndex)
            break
        case InstancesPlacementArea.Mode.Move:
        case InstancesPlacementArea.Mode.SelectMove:
            var instanceBeatPrecision = getScopedBeatPrecision(realMouseBeatPrecision)
            var oldBeat = contentView.placementBeatPrecisionFrom
            if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
                instanceBeatPrecision = instanceBeatPrecision - (instanceBeatPrecision % AudioAPI.beatPrecision)
            else if (contentView.placementBeatPrecisionScale !== 0)
                instanceBeatPrecision = instanceBeatPrecision - (instanceBeatPrecision % contentView.placementBeatPrecisionScale)
            contentView.placementBeatPrecisionTo = instanceBeatPrecision + contentView.placementBeatPrecisionWidth
            contentView.placementBeatPrecisionFrom = instanceBeatPrecision
            if (mode === InstancesPlacementArea.Mode.SelectMove)
                selectionMoveBeatPrecisionOffset += (contentView.placementBeatPrecisionFrom - oldBeat)
            break
        case InstancesPlacementArea.Mode.LeftResize:
        case InstancesPlacementArea.Mode.SelectLeftResize:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale) + (contentView.placementBeatPrecisionFrom % contentView.placementBeatPrecisionScale)
            var oldFrom = contentView.placementBeatPrecisionFrom
            if (contentView.placementBeatPrecisionTo > mouseBeatPrecision)
                contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            else
                contentView.placementBeatPrecisionFrom = contentView.placementBeatPrecisionTo - contentView.placementBeatPrecisionScale
            if (mode === InstancesPlacementArea.Mode.SelectLeftResize && contentView.placementBeatPrecisionFrom != oldFrom)
                selectionList.resizeLeft(contentView.placementBeatPrecisionFrom - oldFrom)
            break
        case InstancesPlacementArea.Mode.RightResize:
        case InstancesPlacementArea.Mode.SelectRightResize:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision + (contentView.placementBeatPrecisionScale - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)) + (contentView.placementBeatPrecisionTo % contentView.placementBeatPrecisionScale)
            var oldTo = contentView.placementBeatPrecisionTo
            if (contentView.placementBeatPrecisionFrom < mouseBeatPrecision)
                contentView.placementBeatPrecisionTo = mouseBeatPrecision
            else
                contentView.placementBeatPrecisionTo = contentView.placementBeatPrecisionFrom + contentView.placementBeatPrecisionScale
            if (mode === InstancesPlacementArea.Mode.SelectRightResize && contentView.placementBeatPrecisionTo != oldTo)
                selectionList.resizeRight(contentView.placementBeatPrecisionTo - oldTo)
            break
        case InstancesPlacementArea.Mode.Brush:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (mouseBeatPrecision >= brushBegin && mouseBeatPrecision <= brushEnd)
                return
            if (mouseBeatPrecision <= brushBegin)
                mouseBeatPrecision = mouseBeatPrecision + (brushBegin - mouseBeatPrecision) - brushWidth
            else
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision - brushEnd)
            brushBegin = mouseBeatPrecision
            brushEnd = mouseBeatPrecision + brushWidth

            // Don't brush over existing instances
            if (brushBegin >= 0 && instances.findOverlap(AudioAPI.beatRange(brushBegin + 1, brushBegin + contentView.placementBeatPrecisionLastWidth - 1)) === -1) {
                instances.add(
                    AudioAPI.beatRange(
                        brushBegin,
                        brushBegin + contentView.placementBeatPrecisionLastWidth
                    )
                )
            }
            break
        case InstancesPlacementArea.Mode.Select:
        case InstancesPlacementArea.Mode.SelectRemove:
            selectionBeatPrecisionTo = realMouseBeatPrecision
            break
        default:
            break
        }
    }

    onReleased: {
        switch (mode) {
        case InstancesPlacementArea.Mode.Move:
        case InstancesPlacementArea.Mode.LeftResize:
        case InstancesPlacementArea.Mode.RightResize:
            contentView.placementBeatPrecisionLastWidth = contentView.placementBeatPrecisionWidth
            instances.add(
                AudioAPI.beatRange(
                    contentView.placementBeatPrecisionFrom,
                    contentView.placementBeatPrecisionTo
                )
            )
            contentView.placementBeatPrecisionMouseOffset = 0
            break
        case InstancesPlacementArea.Mode.Select:
            // Select instances
            var list = instances.select(
                AudioAPI.beatRange(
                    Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo),
                    Math.max(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
                )
            )
            selectionListModel = list
            break
        case InstancesPlacementArea.Mode.SelectRemove:
            // Select instances
            var list = instances.select(
                AudioAPI.beatRange(
                    Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo),
                    Math.max(selectionBeatPrecisionFrom, selectionBeatPrecisionTo)
                )
            )
            instances.removeRange(list)
            break
        case InstancesPlacementArea.Mode.SelectMove:
        case InstancesPlacementArea.Mode.SelectLeftResize:
        case InstancesPlacementArea.Mode.SelectRightResize:
            instances.addRange(selectionList.toList())
            selectionMoveBeatPrecisionOffset = 0
            break
        default:
            break
        }
        contentView.placementRectangle.detach()
        mode = InstancesPlacementArea.Mode.None
    }

    Rectangle {
        color: "transparent"
        border.color: nodeDelegate.node ? Qt.darker(nodeDelegate.node.color, 1.5) : "black"
        border.width: 2
        visible: mode === InstancesPlacementArea.Mode.Brush
        x: contentView.xOffset + brushBegin * contentView.pixelsPerBeatPrecision
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
            var range = item.instance
            if (selectionMoveBeatPrecisionOffset < 0 && -selectionMoveBeatPrecisionOffset > range.from) {
                range.to = range.to - range.from
                range.from = 0
            } else {
                range.from += selectionMoveBeatPrecisionOffset
                range.to += selectionMoveBeatPrecisionOffset
            }
            item.instance = range
            return range
        }

        function resizeLeft(offset) {
            for (var i = 0; i < count; ++i) {
                var item = itemAt(i)
                var range = item.instance
                if (range.from + offset < range.to)
                    range.from += offset
                if (range.from < 0)
                    range.from = 0;
                item.instance = range
            }
        }

        function resizeRight(offset) {
            for (var i = 0; i < count; ++i) {
                var item = itemAt(i)
                var range = item.instance
                if (range.to + offset > range.from)
                    range.to += offset
                item.instance = range
            }
        }

        id: selectionList
        model: selectionListModel

        delegate: Rectangle {
            property var instance: instances.getInstance(modelData)

            x: contentView.xOffset + (selectionMoveBeatPrecisionOffset + instance.from) * contentView.pixelsPerBeatPrecision
            width: (instance.to - instance.from) * contentView.pixelsPerBeatPrecision
            height: contentView.rowHeight
            color: "white"
            opacity: 0.5
        }
    }

    Rectangle {
        id: selectionOverlay
        visible: mode === InstancesPlacementArea.Mode.Select || mode === InstancesPlacementArea.Mode.SelectRemove
        x: contentView.xOffset + Math.min(selectionBeatPrecisionFrom, selectionBeatPrecisionTo) * contentView.pixelsPerBeatPrecision
        width: Math.abs(selectionBeatPrecisionTo - selectionBeatPrecisionFrom) * contentView.pixelsPerBeatPrecision
        height: contentView.rowHeight
        color: "grey"
        opacity: 0.5
        border.color: "white"
        border.width: 1
    }
}
