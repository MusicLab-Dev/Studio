import QtQuick 2.15
import QtQuick.Controls 2.15

import InstancesModel 1.0
import AudioAPI 1.0

MouseArea {
    enum Mode {
        None,
        Remove,
        Move,
        LeftResize,
        RightResize
    }

    property InstancesModel instances: null
    property int mode: InstancesPlacementArea.Mode.None

    id: contentPlacementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    clip: true

    onPressed: {
        var realMouseBeatPrecision = (mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision
        var mouseBeatPrecision = realMouseBeatPrecision
        var instanceIndex = instances.find(mouseBeatPrecision)
        if (mouse.buttons & Qt.RightButton) { // Right click on instance -> delete
            mode = InstancesPlacementArea.Mode.Remove
            if (instanceIndex !== -1)
                instances.remove(instanceIndex)
            return
        }
        if (contentView.placementBeatPrecisionScale !== 0)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)
        contentView.placementRectangle.attach(contentPlacementArea, nodeDelegate.node.color)
        if (instanceIndex === -1) { // Left click not on instance -> insert
            mode = InstancesPlacementArea.Mode.Move
            contentView.placementBeatPrecisionTo = mouseBeatPrecision + contentView.placementBeatPrecisionDefaultWidth
            contentView.placementBeatPrecisionFrom = mouseBeatPrecision
        } else { // Left click on instance -> edit
            var beatPrecisionRange = instances.getInstance(instanceIndex)
            var noteWidth = (beatPrecisionRange.to - beatPrecisionRange.from) * contentView.pixelsPerBeatPrecision
            var resizeThreshold = Math.min(noteWidth * 0.2, contentView.placementResizeMaxPixelThreshold)
            if ((realMouseBeatPrecision - beatPrecisionRange.from) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = InstancesPlacementArea.Mode.LeftResize
            else if ((beatPrecisionRange.to - realMouseBeatPrecision) * contentView.pixelsPerBeatPrecision <= resizeThreshold)
                mode = InstancesPlacementArea.Mode.RightResize
            else
                mode = InstancesPlacementArea.Mode.Move
            instances.remove(instanceIndex)
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
        var mouseBeatPrecision = (mouse.x - contentView.xOffset) / contentView.pixelsPerBeatPrecision
        if (contentView.placementBeatPrecisionScale !== 0)
            mouseBeatPrecision = mouseBeatPrecision - (mouseBeatPrecision % contentView.placementBeatPrecisionScale)
        switch (mode) {
        case InstancesPlacementArea.Mode.Remove:
            var instanceIndex = instances.find(mouseBeatPrecision)
            if (instanceIndex !== -1)
                instances.remove(instanceIndex)
            break
        case InstancesPlacementArea.Mode.Move:
            var beatPrecision = mouseBeatPrecision - contentView.placementBeatPrecisionMouseOffset
            contentView.placementBeatPrecisionTo = beatPrecision + contentView.placementBeatPrecisionWidth
            contentView.placementBeatPrecisionFrom = beatPrecision
            break
        case InstancesPlacementArea.Mode.LeftResize:
            if (contentView.placementBeatPrecisionTo > mouseBeatPrecision)
                contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            else
                mode = InstancesPlacementArea.Mode.RightResize
            break
        case InstancesPlacementArea.Mode.RightResize:
            if (contentView.placementBeatPrecisionFrom < mouseBeatPrecision)
                contentView.placementBeatPrecisionTo = mouseBeatPrecision
            else
                mode = InstancesPlacementArea.Mode.LeftResize
            break
        default:
            break
        }
    }
}