import QtQuick 2.15
import QtQuick.Controls 2.15


Slider {
    id: control
    width: parent.width
    height: parent.height
    hoverEnabled: true

    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onPressedChanged: canvas.requestPaint()
    onHoveredChanged: canvas.requestPaint()

    background: Rectangle {
        id: background
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 8
        color: "#295F8B"

        Repeater {
            readonly property real rangeWidth: range[1] - range[0]
            readonly property real stepCount: rangeWidth / range[2]
            property real stepWidth: background.width / stepCount

            id: rep
            width: parent.width
            height: parent.height
            model: stepCount + 1

            delegate: Rectangle {
                id: rect
                width: 2
                height: 15
                x: index * rep.stepWidth - width / 2
                y: background.height / 2 - height / 2
                radius: width * 0.5
                color: "#295F8B"
            }
        }
    }

    handle: Canvas {
        id: canvas

        x: control.leftPadding + control.visualPosition * control.availableWidth - width / 2
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 20
        implicitHeight: 20
        contextType: "2d"

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.pressed ? themeManager.accentColor : control.hovered ? "#0D86CB" : "#295F8B";
            context.fill();
        }
    }
}
