import QtQuick 2.15

MouseArea {
    signal xZoomed(real zoom, real xPos)
    signal yZoomed(real zoom, real yPos)
    signal xScrolled(real scroll, real xPos)
    signal yScrolled(real scroll, real yPos)

    id: gestureArea
    propagateComposedEvents: true
    // hoverEnabled: true

    onClicked: mouse.accepted = false
    onPressed: mouse.accepted = false
    onReleased: mouse.accepted = false
    onDoubleClicked: mouse.accepted = false
    onPositionChanged: mouse.accepted = false
    onPressAndHold: mouse.accepted = false

    onWheel: {
        var multiplier = wheel.modifiers & Qt.ShiftModifier ? 3 : 1
        if (wheel.modifiers & Qt.ControlModifier) {
            if (wheel.angleDelta.y !== 0)
                xZoomed(wheel.angleDelta.y * multiplier, wheel.x)
            else if (wheel.angleDelta.x !== 0)
                yZoomed(wheel.angleDelta.x * multiplier, wheel.y)
        } else {
            if (wheel.angleDelta.x !== 0)
                xScrolled(wheel.angleDelta.x * multiplier, wheel.x)
            else if (wheel.angleDelta.y !== 0)
                yScrolled(wheel.angleDelta.y * multiplier, wheel.y)
        }
    }
}
