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

    ToolTip.visible: hovered || pressed
    ToolTip.text: tooltipPrefixText + controlValue.toFixed() + tooltipSufixText

    Component.onCompleted: value = Math.floor(controlValue)

    Binding {
        target: control
        property: "value"
        value: Math.floor(controlValue)
    }

    onValueChanged: {
        var fixed = Math.floor(value)
        if (Math.floor(controlValue) === fixed)
            controlValue = fixed
    }
}