import QtQuick 2.15
import QtQuick.Controls 2.15

import InstancesModel 1.0
import AudioAPI 1.0

import ".."

MouseArea {
    enum Mode {
        None,
        Remove,
        Move,
        LeftResize,
        RightResize,
        Brush
    }

    property InstancesModel instances: null
    property int mode: InstancesPlacementArea.Mode.None
    property int brushBegin: 0
    property int brushEnd: 0
    property int brushStep: 0

    id: contentPlacementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    clip: true

    onPressed: {
        var realMouseBeatPrecision = (mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision
        var instanceIndex = instances.find(realMouseBeatPrecision)

        // Right click on instance -> delete
        if (mouse.buttons & Qt.RightButton) {
            mode = InstancesPlacementArea.Mode.Remove
            if (instanceIndex !== -1)
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
            if (contentView.placementBeatPrecisionLastWidth === 0)
                contentView.placementBeatPrecisionLastWidth = contentView.placementBeatPrecisionDefaultWidth
            // Brush mode, insert note directly
            if (playlistView.editMode === PlaylistView.EditMode.Brush) {
                mode = InstancesPlacementArea.Mode.Brush
                brushBegin = mouseBeatPrecision
                brushEnd = mouseBeatPrecision + contentView.placementBeatPrecisionLastWidth
                instances.add(AudioAPI.beatRange(brushBegin, brushEnd))
            // Move mode, attach preview
            } else {
                // Attach the preview
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
            contentView.placementBeatPrecisionLastWidth = instanceWidthBeatPrecision
            if ((realMouseBeatPrecision - beatPrecisionRange.from) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = InstancesPlacementArea.Mode.LeftResize
            else if ((beatPrecisionRange.to - realMouseBeatPrecision) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = InstancesPlacementArea.Mode.RightResize
            else
                mode = InstancesPlacementArea.Mode.Move
            instances.remove(instanceIndex)
            // Attach the preview
            contentView.placementRectangle.attach(contentPlacementArea, nodeDelegate.node.color)
            contentView.placementBeatPrecisionFrom = beatPrecisionRange.from
            contentView.placementBeatPrecisionTo = beatPrecisionRange.to
            contentView.placementBeatPrecisionMouseOffset = mouseBeatPrecision - beatPrecisionRange.from
        }
    }

    onReleased: {
        switch (mode) {
        case InstancesPlacementArea.Mode.Move:
        case InstancesPlacementArea.Mode.LeftResize:
        case InstancesPlacementArea.Mode.RightResize:
            if (contentView.placementBeatPrecisionFrom < 0)
                contentView.placementBeatPrecisionFrom = 0
            contentView.placementBeatPrecisionLastWidth = contentView.placementBeatPrecisionWidth
            instances.add(AudioAPI.beatRange(contentView.placementBeatPrecisionFrom, contentView.placementBeatPrecisionTo))
            contentView.placementBeatPrecisionMouseOffset = 0
            break;
        default:
            break;
        }
        contentView.placementRectangle.detach()
        mode = InstancesPlacementArea.Mode.None
    }

    onPositionChanged: {
        var realMouseBeatPrecision = (mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision
        switch (mode) {
        case InstancesPlacementArea.Mode.Remove:
            var noteIndex = instances.find(realMouseBeatPrecision)
            if (noteIndex !== -1)
                instances.remove(noteIndex)
            break
        case InstancesPlacementArea.Mode.Move:
            var mouseBeatPrecision = realMouseBeatPrecision - contentView.placementBeatPrecisionMouseOffset
            if (contentView.placementBeatPrecisionScale >= AudioAPI.beatPrecision)
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % AudioAPI.beatPrecision)
            else if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)
            contentView.placementBeatPrecisionTo = mouseBeatPrecision + contentView.placementBeatPrecisionWidth
            contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            break
        case InstancesPlacementArea.Mode.LeftResize:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale) + (contentView.placementBeatPrecisionFrom % contentView.placementBeatPrecisionScale)
            if (contentView.placementBeatPrecisionTo > mouseBeatPrecision)
                contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            else
                mode = InstancesPlacementArea.Mode.RightResize
            break
        case InstancesPlacementArea.Mode.RightResize:
            var mouseBeatPrecision = realMouseBeatPrecision
            if (contentView.placementBeatPrecisionScale !== 0)
                mouseBeatPrecision = mouseBeatPrecision + (contentView.placementBeatPrecisionScale - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)) + (contentView.placementBeatPrecisionTo % contentView.placementBeatPrecisionScale)
            if (contentView.placementBeatPrecisionFrom < mouseBeatPrecision)
                contentView.placementBeatPrecisionTo = mouseBeatPrecision
            else
                mode = InstancesPlacementArea.Mode.LeftResize
            break
        case InstancesPlacementArea.Mode.Brush:
            var mouseBeatPrecision = realMouseBeatPrecision
            var outsideBegin = mouseBeatPrecision < brushBegin
            var outsideEnd = mouseBeatPrecision > brushEnd
            var outsideRange = outsideBegin || outsideEnd
            if (brushStep !== 0) {
                var tmp = contentView.placementBeatPrecisionLastWidth + brushStep
                if (outsideEnd)
                    mouseBeatPrecision = mouseBeatPrecision + (tmp - (mouseBeatPrecision % tmp)) + (brushEnd % tmp)
                else
                    mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % tmp) + (brushBegin % tmp)
            } else {
                if (outsideEnd)
                    mouseBeatPrecision = mouseBeatPrecision + (contentView.placementBeatPrecisionLastWidth - (mouseBeatPrecision % contentView.placementBeatPrecisionLastWidth)) + (brushEnd % contentView.placementBeatPrecisionLastWidth)
                else
                    mouseBeatPrecision = mouseBeatPrecision - ((mouseBeatPrecision - (brushBegin % contentView.placementBeatPrecisionLastWidth)) % contentView.placementBeatPrecisionLastWidth)
            }
            // Check if we should create a new instance
            if (outsideRange) {
                if (outsideEnd) {
                    brushBegin = mouseBeatPrecision - contentView.placementBeatPrecisionLastWidth
                    brushEnd = mouseBeatPrecision
                } else {
                    brushBegin = mouseBeatPrecision
                    brushEnd = mouseBeatPrecision + contentView.placementBeatPrecisionLastWidth
                }
                // Don't overwrite over existing instances
                if (instances.findOverlap(brushBegin + 1, brushEnd - 1) === -1)
                    instances.add(AudioAPI.beatRange(brushBegin, brushEnd))
            }
            break
        default:
            break
        }
    }
}