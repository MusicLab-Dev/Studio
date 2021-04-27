import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

DefaultPotentiometer {
    readonly property int range: Math.abs(Math.max(controlMinValue, controlMaxValue) - Math.min(controlMinValue, controlMaxValue))
    readonly property real currentRatio: (controlValue - controlMinValue) / range
    readonly property real stepRatio: controlStepValue === 0 ? 0.05 : controlStepValue / range
    property real rest: 0

    onCurrentRatioChanged: value = currentRatio

    width: 50
    height: 50
    stepSize: stepRatio

    ToolTip.visible: dial.hovered || dial.pressed
    ToolTip.text: controlTitle + ": " + controlValue.toFixed(2) + "\n" + controlDescription

    onValueChanged: {
        if (Math.abs(value - currentRatio) < Number.EPSILON)
            return
        var ratio = value
        if (ratio < 0)
            ratio = 0
        else if (ratio > 1)
            ratio = 1
        controlValue = controlMinValue + range * ratio
    }
}