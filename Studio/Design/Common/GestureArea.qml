import QtQuick 2.15

MouseArea {
    signal xZoomed(real zoom, real xPos, real yPos)
    signal yZoomed(real zoom, real xPos, real yPos)
    signal xScrolled(real scroll, real xPos, real yPos)
    signal yScrolled(real scroll, real xPos, real yPos)
    signal offsetScroll(real xOffset, real yOffset)

    property bool isDragging: false
    property point lastDragEvent: Qt.point(0, 0)

    id: gestureArea
    propagateComposedEvents: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onClicked: mouse.accepted = false
    onReleased: mouse.accepted = false
    onDoubleClicked: mouse.accepted = false
    onPressAndHold: mouse.accepted = false

    onPressed: {
        forceActiveFocus()
        if (mouse.buttons & Qt.MiddleButton) {
            isDragging = true
            lastDragEvent = Qt.point(mouse.x, mouse.y)
        } else
            mouse.accepted = false
    }

    onPositionChanged: {
        if (isDragging) {
            var dragEvent = Qt.point(mouse.x, mouse.y)
            offsetScroll(dragEvent.x - lastDragEvent.x, dragEvent.y - lastDragEvent.y)
            lastDragEvent = dragEvent
        } else {
            mouse.accepted = false
        }
    }

    onWheel: {
        var multiplier = wheel.modifiers & Qt.ShiftModifier ? 3 : 1
        if (wheel.modifiers & Qt.ControlModifier) {
            if (wheel.angleDelta.y !== 0)
                xZoomed(wheel.angleDelta.y * multiplier, wheel.x, wheel.y)
            else if (wheel.angleDelta.x !== 0)
                yZoomed(wheel.angleDelta.x * multiplier, wheel.x, wheel.y)
        } else {
            if (wheel.angleDelta.x !== 0)
                xScrolled(wheel.angleDelta.x * multiplier, wheel.x, wheel.y)
            else if (wheel.angleDelta.y !== 0)
                yScrolled(wheel.angleDelta.y * multiplier, wheel.x, wheel.y)
        }
    }
}
