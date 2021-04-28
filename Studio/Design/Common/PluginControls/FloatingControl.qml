import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

DefaultPotentiometer {
    width: 50
    height: 50
    minimumValue: controlMinValue
    maximumValue: controlMaxValue
    stepSize: controlStepValue

    ToolTip.visible: hovered || pressed
    ToolTip.text: controlTitle + ": " + controlValue.toFixed(2) + "\n" + controlDescription

    onValueChanged: {
        if (Math.abs(value - controlValue) > Number.EPSILON)
            controlValue = value
    }
}