import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

BaseRangeControl {

    id: control
    value: controlValue
    minimumValue: controlMinValue
    maximumValue: controlMaxValue
    stepSize: controlStepValue
    longName: controlTitle
    shortName: controlShortName
    unitName: controlUnitName
    description: controlDescription

    onEdited: controlValue = editedValue
}
