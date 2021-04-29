import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

DefaultComboBox {
    readonly property string tooltipPrefixText: controlTitle + ": "
    readonly property string tooltipSufixText: " " + controlUnitName + "\n" + controlDescription

    width: 100
    height: 50
    model: controlRangeNames
    currentIndex: controlValue

    ToolTip.visible: hovered || pressed
    ToolTip.text: tooltipPrefixText + currentText + tooltipSufixText

    onAccepted: controlValue = currentIndex
}
