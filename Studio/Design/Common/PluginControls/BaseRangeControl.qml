import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

MouseArea {
    function incrementValue(offset) {
        valueRatio = Math.max(Math.min(valueRatio + offset / pixelsRange, 1), 0)
        var editedValue = (minimumValue + valueRatio * rangeValue) / stepSize
        if (offset < 0)
            editedValue = Math.ceil(editedValue) * stepSize
        else
            editedValue = Math.floor(editedValue) * stepSize
        if (editedValue !== value)
            edited(editedValue)
    }

    // Inputs
    property real value: 0
    property real minimumValue: 0
    property real maximumValue: 1
    property real stepSize: 0.1
    property string longName: ""
    property string shortName: ""
    property string unitName: ""
    property string description: ""
    property color accentColor: themeManager.accentColor

    // States
    property bool tracking: false
    property bool preventNoiseEvents: false
    property point lastTrackingPos: Qt.point(0, 0)

    // Cache
    property real valueRatio: 0
    readonly property real rangeValue: maximumValue - minimumValue
    readonly property real valueRealRatio: (value - minimumValue) / rangeValue
    readonly property real pixelsRange: 600 // Represent the total range as pixels to travel

    // Tooltip
    readonly property string tooltipPrefixText: longName + ": "
    readonly property string tooltipSufixText: " " + unitName + "\n" + description
    readonly property int digitCount: {
        var str = stepSize.toString()
        var idx = str.indexOf(".")
        var digits = 0
        if (idx !== -1)
            digits = Math.max(str.length - idx - 1, 1)
        return digits
    }

    signal edited(real editedValue)

    id: control
    width: 40
    height: 40
    hoverEnabled: !tracking

    Component.onCompleted: valueRatio = (value - minimumValue) / rangeValue

    onEdited: value = editedValue

    onValueChanged: {
        valueRatio = (value - minimumValue) / rangeValue
    }

    onPressedChanged: {
        if (pressed) {
            tracking = true
            app.setCursorVisibility(false)
            lastTrackingPos = Qt.point(mouseX, mouseY)
        } else {
            app.setCursorVisibility(true)
            tracking = false
        }
    }

    onPositionChanged: {
        if (tracking && !preventNoiseEvents) {
            var speedMultiplier = mouse.modifiers & Qt.ControlModifier ? 0.5 : mouse.modifiers & Qt.ShiftModifier ? 2 : 1
            var offset = -(mouseY - lastTrackingPos.y) * speedMultiplier
            if (offset !== 0) {
                preventNoiseEvents = true
                incrementValue(offset)
                app.setCursorPos(control.mapToGlobal(lastTrackingPos))
                preventNoiseEvents = false
            }
        }
    }

    DefaultToolTip { // @todo make this a unique instance
        visible: control.tracking || control.containsMouse
        text: tooltipPrefixText + value.toFixed(digitCount) + tooltipSufixText
        accentColor: control.accentColor
    }

    Rectangle {
        id: controlCircle
        anchors.fill: parent
        color: "transparent"
        radius: width / 2
        border.color: control.containsMouse || control.tracking ? control.accentColor : "white"
        border.width: 1

        DefaultText {
            text: control.shortName
            anchors.fill: parent
            fontSizeMode: Text.Fit
            color: control.tracking ? control.accentColor : "white"
        }

        Item {
            id: currentTickmark
            anchors.fill: parent
            transformOrigin: Item.Center
            rotation: valueRealRatio * 270 - 135

            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: 6
                height: 6
                radius: 3
                color: Qt.darker("white", 1.65 - 0.65 * valueRealRatio)
            }
        }

        Rectangle {
            id: minTickmark
            anchors.bottom: parent.bottom
            width: 6
            height: 6
            radius: 3
            color: "grey"
        }

        Rectangle {
            id: maxTickmark
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 6
            height: 6
            radius: 3
            color: "white"
        }
    }
}