import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

MouseArea {
    readonly property int range: Math.abs(Math.max(controlMinValue, controlMaxValue) - Math.min(controlMinValue, controlMaxValue))
    readonly property real currentRatio: (controlValue - controlMinValue) / range
    readonly property real stepRatio: controlStepValue === 0 ? 0.05 : controlStepValue / range
    property real rest: 0

    id: mouseArea
    width: 30
    height: 30
    hoverEnabled: true

    onWheel: {
        var delta = wheel.angleDelta.y / 15 * stepRatio
        var ratio = currentRatio + delta + rest
        rest = delta % controlStepValue
        if (ratio < 0)
            ratio = 0
        else if (ratio > 1)
            ratio = 1
        controlValue = controlMinValue + range * ratio
    }

    ToolTip.visible: mouseArea.containsMouse
    ToolTip.text: controlTitle + ": " + controlValue.toFixed() + "\n" + controlDescription

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#001E36"
        radius: width / 2
        transformOrigin: Item.Center
        border.width: mouseArea.containsMouse ? 2 : 1
        border.color: "grey"
        rotation: (-180 + 30) + currentRatio * (360 - 30 * 2)

        Rectangle {
            x: 14
            y: 1
            width: 2
            height: 14
            color: "#31A8FF"
        }
    }
}