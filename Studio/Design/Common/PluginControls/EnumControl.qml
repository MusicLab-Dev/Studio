import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

DefaultComboBox {
    readonly property string tooltipPrefixText: controlTitle + ": "
    readonly property string tooltipSufixText: " " + controlUnitName + "\n" + controlDescription

    id: control
    width: 120
    height: 40
    model: controlRangeNames

    onActivated: controlValue = index

    Component.onCompleted: currentIndex = controlValue

    DefaultToolTip { // @todo make this a unique instance
        visible: hovered || pressed
        text: tooltipPrefixText + currentText + tooltipSufixText
        accentColor: control.accentColor
    }

    Binding {
        target: control
        property: "currentIndex"
        value: controlValue
    }
}
