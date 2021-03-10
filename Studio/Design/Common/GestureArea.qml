import QtQuick 2.15

MouseArea {
    signal zoomed(real zoomX, real zoomY)

    id: gestureArea
    propagateComposedEvents: true

    onClicked: mouse.accepted = false
    onPressed: mouse.accepted = false
    onReleased: mouse.accepted = false
    onDoubleClicked: mouse.accepted = false
    onPositionChanged: mouse.accepted = false
    onPressAndHold: mouse.accepted = false

    onWheel: {
        if (wheel.modifiers & Qt.ControlModifier) {
            zoomed(wheel.angleDelta.x, wheel.angleDelta.y)
        } else 
            wheel.accepted = false
    }
}
