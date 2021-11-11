import QtQuick 2.15

import "../Default"

import AudioAPI 1.0
import AutomationModel 1.0

MouseArea {
    function mouseBeatPrecision() {
        return Math.max((mouseX - contentView.xOffset) / contentView.pixelsPerBeatPrecision, 0)
    }

    function getPointY(value) {
        return height * (1 - ((value - controlDescriptor.controlMinValue) / controlRangeValue))
    }

    function addPoint() {
        var targetBeatPrecision = mouseBeatPrecision()
        var point = AudioAPI.point(
            targetBeatPrecision,
            Point.CurveType.Linear,
            0,
            (1 - (mouseY / height)) * controlRangeValue + controlDescriptor.controlMinValue
        )
        point.value = Math.min(Math.max(point.value, controlDescriptor.controlMinValue), controlDescriptor.controlMaxValue)
        automation.add(point)
    }

    // Inputs
    property AutomationModel automation: null
    property var controlDescriptor: undefined
    property real controlRangeValue: controlDescriptor !== undefined ? controlDescriptor.controlMaxValue - controlDescriptor.controlMinValue : 0

    // Remove cache
    property bool isRemoving: false
    property int removeFromBeatPrecision: 0
    property int removeToBeatPrecision: 0

    id: automationRow
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    enabled: automation != null && controlDescriptor != undefined

    onPressed: {
        if (mouse.button === Qt.RightButton) {
            isRemoving = true
            removeFromBeatPrecision = mouseBeatPrecision()
            removeToBeatPrecision = removeFromBeatPrecision
        } else {
            isRemoving = false
            addPoint()
        }
    }

    onPositionChanged: {
        if (isRemoving)
            removeToBeatPrecision = mouseBeatPrecision()
    }

    onReleased: {
        if (isRemoving) {
            isRemoving = false
            automation.removeSelection(AudioAPI.beatRange(
                Math.min(removeFromBeatPrecision, removeToBeatPrecision),
                Math.max(removeFromBeatPrecision, removeToBeatPrecision)
            ))
        }
    }

    Rectangle {
        id: selectionOverlay
        visible: isRemoving
        x: contentView.xOffset + Math.min(removeFromBeatPrecision, removeToBeatPrecision) * contentView.pixelsPerBeatPrecision
        width: Math.abs(removeToBeatPrecision - removeFromBeatPrecision) * contentView.pixelsPerBeatPrecision
        height: parent.height
        color: "grey"
        opacity: 0.5
        border.color: "white"
        border.width: 1
    }
}
