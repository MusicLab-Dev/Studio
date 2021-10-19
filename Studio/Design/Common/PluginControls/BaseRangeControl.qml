import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

import CursorManager 1.0

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
    property real defaultValue: 0
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
    readonly property real pixelsRange: (rangeValue / stepSize) * 2 // Represent the total range as pixels to travel

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
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: {
        if (mouse.button == Qt.RightButton)
            value = defaultValue
    }

    onWheel: {
        /*if (wheel.angleDelta.y != 0) {
            tracking = false
            app.setCursorVisibility(true)
        } else {
            tracking = true
            app.setCursorVisibility(false)
            lastTrackingPos = Qt.point(0, wheel.angleDelta.y)
        }*/
    }

    onHoveredChanged: {
        if (pressed)
            return
        if (containsMouse)
            cursorManager.set(CursorManager.Type.Pressable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    Component.onCompleted: {
        valueRatio = (value - minimumValue) / rangeValue
    }

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
            var speedMultiplier = mouse.modifiers & Qt.ControlModifier ? 0.25 : mouse.modifiers & Qt.ShiftModifier ? 4 : 1
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


    Canvas {
        readonly property real startAngle: Math.PI * 0.75
        readonly property real endAngle: Math.PI * 2.25
        readonly property real stopAngle: Math.PI * (control.valueRatio * 1.5 + 0.75)
        readonly property real targetSizeRatio: 0.45

        id: controlCircle
        anchors.fill: parent
        antialiasing: true

        onStopAngleChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            var targetSize = width * targetSizeRatio
            var center = Qt.point(width / 2, height / 2)
            ctx.reset()
            ctx.lineWidth = 4
            ctx.strokeStyle = control.accentColor
            ctx.beginPath()
            ctx.arc(center.x, center.y, targetSize, startAngle, stopAngle, false)
            ctx.stroke()
            if (stopAngle !== endAngle) {
                ctx.beginPath()
                ctx.strokeStyle = themeManager.backgroundColor
                ctx.arc(center.x, center.y, targetSize, stopAngle, endAngle, false)
                ctx.stroke()
            }
        }

        DefaultText {
            text: control.shortName
            anchors.fill: parent
            anchors.margins: 6
            fontSizeMode: Text.Fit
            color: control.tracking ? control.accentColor : "white"
            elide: Text.ElideRight
        }
    }
}
