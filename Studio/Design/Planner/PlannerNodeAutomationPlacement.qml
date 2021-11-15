import QtQuick 2.15

import "../Default"

import AudioAPI 1.0
import AutomationModel 1.0
import AutomationPreview 1.0

MouseArea {
    enum Mode {
        None,
        Insert,
        Remove
    }

    function mouseBeatPrecision() {
        var mouseBeat = Math.max((mouseX - contentView.xOffset) / contentView.pixelsPerBeatPrecision, 0)
        return Math.max(mouseBeat - (mouseBeat % 32), 0)
    }

    function mouseParamValue() {
        var value = (1 - (mouseY / height)) * controlRangeValue + controlDescriptor.controlMinValue
        value = Math.min(Math.max(value, controlDescriptor.controlMinValue), controlDescriptor.controlMaxValue)
        return value - (value % controlDescriptor.controlStepValue)
    }

    function pixelsToBeatPrecision(pixels) {
        return pixels / pixelsPerBeatPrecision
    }

    function pixelsToValue(pixels) {
        return (1 - (pixels / height)) * controlRangeValue + controlDescriptor.controlMinValue
    }

    function resetCache() {
        mode = PlannerNodeAutomationPlacement.Mode.None
        hoverIndex = -1
    }

    function updatePreview() {
        previewPoint = Qt.point(
            Math.max(Math.min(mouseX - (mouseX % (contentView.pixelsPerBeatPrecision * 32)), width), 0),
            Math.max(Math.min(mouseY - (mouseY % pixelsPerStepValue), height), 0)
        )
    }

    function insertPreview() {
        var mouseBeat = mouseBeatPrecision()
        var mouseValue = mouseParamValue()
        var point = AudioAPI.point(
            mouseBeat,
            Point.CurveType.Linear,
            0,
            mouseValue
        )
        automation.add(point)
    }

    function initRemovePreview() {
        var mouseBeat = mouseBeatPrecision()
        removeRange = AudioAPI.beatRange(mouseBeat, mouseBeat + 32)
    }

    function updateRemovePreview() {
        var mouseBeat = mouseBeatPrecision()
        if (mouseBeat != removeRange.from)
            removeRange = AudioAPI.beatRange(removeRange.from, mouseBeat)
    }

    function removeSelection() {
        if (removeRange.from > removeRange.to)
            removeRange = AudioAPI.beatRange(removeRange.to, removeRange.from)
        automation.removeSelection(removeRange)
    }


    // Inputs
    property AutomationModel automation: null
    property AutomationPreview preview: null
    property var controlDescriptor: undefined
    property real controlRangeValue: controlDescriptor !== undefined ? controlDescriptor.controlMaxValue - controlDescriptor.controlMinValue : 0

    // Edition Cache
    property int mode: PlannerNodeAutomationPlacement.Mode.None
    property var removeRange: AudioAPI.beatRange(0, 0)
    property point previewPoint: Qt.point(0, 0)
    property int hoverIndex: -1
    property point hoverPoint: Qt.point(0, 0)

    // Cache
    property real pixelsPerStepValue: controlDescriptor !== undefined ? height / (controlRangeValue / controlDescriptor.controlStepValue) : 0

    id: automationRow
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    enabled: automation !== null && preview !== null && controlDescriptor !== undefined
    hoverEnabled: true

    onPressed: {
        resetCache()
        var idx = preview.findPoint(Qt.point(mouseX, mouseY))
        if (idx !== -1 && !automation.remove(idx))
            return // Abort on remove failure
        if (mouse.button === Qt.RightButton) {
            if (idx !== -1)
                return
            mode = PlannerNodeAutomationPlacement.Mode.Remove
            initRemovePreview()
        } else {
            mode = PlannerNodeAutomationPlacement.Mode.Insert
            updatePreview()
        }
    }

    onPositionChanged: {
        switch (mode) {
        case PlannerNodeAutomationPlacement.Mode.Insert:
            return updatePreview()
        case PlannerNodeAutomationPlacement.Mode.Remove:
            return updateRemovePreview()
        default:
            hoverIndex = preview.findPoint(Qt.point(mouseX, mouseY))
            if (hoverIndex !== -1) {
                hoverPoint = preview.getVisualPoint(hoverIndex)
            }
            break
        }
    }

    onReleased: {
        switch (mode) {
        case PlannerNodeAutomationPlacement.Mode.Insert:
            insertPreview()
            break;
        case PlannerNodeAutomationPlacement.Mode.Remove:
            removeSelection()
            break
        default:
            break
        }
        resetCache()
    }

    Rectangle {
        id: selectionOverlay
        visible: mode === PlannerNodeAutomationPlacement.Mode.Remove
        x: contentView.xOffset + Math.min(removeRange.from, removeRange.to) * contentView.pixelsPerBeatPrecision
        width: Math.abs(removeRange.to - removeRange.from) * contentView.pixelsPerBeatPrecision
        height: parent.height
        color: "grey"
        opacity: 0.5
        border.color: "white"
        border.width: 1
    }

    Rectangle {
        id: pointPreview
        visible: mode === PlannerNodeAutomationPlacement.Mode.Insert
        x: previewPoint.x - 5
        y: previewPoint.y - 5
        radius: 5
        width: 10
        height: 10
        color: preview ? Qt.darker(preview.color, 1.6) : "white"
    }

    Rectangle {
        id: pointHover
        visible: hoverIndex !== -1
        x: hoverPoint.x - 10
        y: hoverPoint.y - 10
        radius: 10
        width: 20
        height: 20
        color: pointPreview.color
    }

    DefaultToolTip {
        id: toolTip
        parent: pointPreview.visible ? pointPreview : pointHover.visible ? pointHover : automationRow
        visible: parent != automationRow
        text: {
            if (pointPreview.visible) {
                return pixelsToValue(previewPoint.y).toFixed(3)
            } else if (pointHover.visible) {
                var point = automation.getPoint(hoverIndex)
                return point.value.toFixed(3)
            } else
                return ""
        }
    }
}
