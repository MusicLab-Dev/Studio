import QtQuick 2.15

MouseArea {
    signal zoomed(real zoomX, real zoomY)
    signal scrolled(real scrollX, real scrollY)

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
        if (wheel.modifiers & Qt.ControlModifier)
            zoomed(wheel.angleDelta.x, wheel.angleDelta.y)
        else
            scrolled(wheel.angleDelta.x, wheel.angleDelta.y)
    }
}
