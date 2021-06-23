import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

DefaultPotentiometer {
    readonly property string tooltipPrefixText: controlTitle + ": "
    readonly property string tooltipSufixText: " " + controlUnitName + "\n" + controlDescription
    readonly property int digitCount: {
        var str = controlStepValue.toString()
        var idx = str.indexOf(".")
        var digits = 2
        if (idx !== -1)
            digits = Math.max(str.length - idx - 1, 2)
        return digits
    }

    id: control
    width: 50
    height: 50
    minimumValue: controlMinValue
    maximumValue: controlMaxValue
    stepSize: controlStepValue
    text: controlShortName

    ToolTip.visible: hovered || pressed
    ToolTip.text: tooltipPrefixText + controlValue.toFixed(digitCount) + tooltipSufixText

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