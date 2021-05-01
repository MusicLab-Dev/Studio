import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

DefaultPotentiometer {
    readonly property string tooltipPrefixText: controlTitle + ": "
    readonly property string tooltipSufixText: " " + controlUnitName + "\n" + controlDescription

    width: 50
    height: 50
    minimumValue: controlMinValue
    maximumValue: controlMaxValue
    stepSize: controlStepValue
    text: controlShortName

    ToolTip.visible: hovered || pressed
    ToolTip.text: tooltipPrefixText + controlValue.toFixed(2) + tooltipSufixText

    onValueChanged: {
        if (Math.abs(value - controlValue) > Number.EPSILON)
            controlValue = value
    }
}