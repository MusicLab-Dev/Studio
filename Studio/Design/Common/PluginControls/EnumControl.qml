import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

DefaultComboBox {
    readonly property string tooltipPrefixText: controlTitle + ": "
    readonly property string tooltipSufixText: " " + controlUnitName + "\n" + controlDescription

    id: control
    width: 100
    height: 30
    model: controlRangeNames

    ToolTip.visible: hovered || pressed
    ToolTip.text: tooltipPrefixText + currentText + tooltipSufixText

    Component.onCompleted: currentIndex = controlValue

    Binding {
        target: control
        property: "currentIndex"
        value: controlValue
    }

    onActivated: controlValue = index
}
