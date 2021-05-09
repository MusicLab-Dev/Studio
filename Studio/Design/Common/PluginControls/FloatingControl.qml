import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

DefaultPotentiometer {
    readonly property string tooltipPrefixText: controlTitle + ": "
    readonly property string tooltipSufixText: " " + controlUnitName + "\n" + controlDescription

    id: control
    width: 50
    height: 50
    minimumValue: controlMinValue
    maximumValue: controlMaxValue
    stepSize: controlStepValue
    text: controlShortName

    ToolTip.visible: hovered || pressed
    ToolTip.text: tooltipPrefixText + controlValue.toFixed(2) + tooltipSufixText

    Component.onCompleted: value = controlValue

    Binding {
        target: control
        property: "value"
        value: controlValue
    }

    onValueChanged: {
        if (Math.abs(value - controlValue) > Number.EPSILON)
            controlValue = value
    }
}