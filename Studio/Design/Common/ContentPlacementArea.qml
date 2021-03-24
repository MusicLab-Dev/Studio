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
    property int mode: ContentPlacementArea.Mode.None

    id: contentPlacementArea
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    clip: true

    onPressed: {
        var mouseBeatPrecision = (contentView.xOffset + mouse.x) / contentView.pixelsPerBeatPrecision
        var instanceIndex = instances.find(mouseBeatPrecision)
        if (mouse.buttons & Qt.RightButton) { // Right click on instance -> delete
            mode = ContentPlacementArea.Mode.Remove
            if (instanceIndex !== -1)
                instances.remove(instanceIndex)
            return
        }
        contentView.placementRectangle.attach(contentPlacementArea, nodeDelegate.node.color)
        if (instanceIndex === -1) { // Left click not on instance -> insert
            mode = ContentPlacementArea.Mode.Move
            contentView.placementBeatPrecisionTo = mouseBeatPrecision + contentView.placementBeatPrecisionDefaultWidth
            contentView.placementBeatPrecisionFrom = mouseBeatPrecision
        } else { // Left click on instance -> edit
            var beatPrecisionRange = instances.getInstance(instanceIndex)
            mode = ContentPlacementArea.Mode.Move
            instances.remove(instanceIndex)
            contentView.placementBeatPrecisionFrom = beatPrecisionRange.from
            contentView.placementBeatPrecisionTo = beatPrecisionRange.to
            contentView.placementBeatPrecisionMouseOffset = mouseBeatPrecision - beatPrecisionRange.from
        }
    }

    onReleased: {
        switch (mode) {
        case ContentPlacementArea.Mode.Move:
            if (contentView.placementBeatPrecisionFrom >= 0)
                instances.add(AudioAPI.beatRange(contentView.placementBeatPrecisionFrom, contentView.placementBeatPrecisionTo))
            contentView.placementBeatPrecisionMouseOffset = 0
            break;
        default:
            break;
        }
        contentView.placementRectangle.detach()
        mode = ContentPlacementArea.Mode.None
    }

    onPositionChanged: {
        var mouseBeatPrecision = (contentView.xOffset + mouse.x) / contentView.pixelsPerBeatPrecision
        switch (mode) {
        case ContentPlacementArea.Mode.Remove:
            var instanceIndex = instances.find(mouseBeatPrecision)
            if (instanceIndex !== -1)
                instances.remove(instanceIndex)
            break
        case ContentPlacementArea.Mode.Move:
            var beatPrecision = mouseBeatPrecision - contentView.placementBeatPrecisionMouseOffset
            console.log(mouseBeatPrecision, beatPrecision, contentView.placementBeatPrecisionWidth)
            contentView.placementBeatPrecisionTo = beatPrecision + contentView.placementBeatPrecisionWidth
            contentView.placementBeatPrecisionFrom = beatPrecision
            break
        case ContentPlacementArea.Mode.LeftResize:
            contentView.placementBeatPrecisionFrom = mouseBeatPrecision
            break
        case ContentPlacementArea.Mode.RightResize:
            contentView.placementBeatPrecisionTo = mouseBeatPrecision
            break
        default:
            break
        }
    }
}