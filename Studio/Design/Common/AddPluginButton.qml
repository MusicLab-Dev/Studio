import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    hoverEnabled: true

    background: Rectangle {
        width: control.width
        height: control.height
        opacity: control.pressed ? 0.85 : control.hovered ? 0.75 : 0.63
        color: control.pressed ? "#223B50" : control.hovered ? "#394F61" : "#546776"
        radius: width / 11
    }

    indicator: Canvas {
        id: canvas
        anchors.centerIn: control
        width: Math.min(control.width, control.height) / 2.5
        height: width
        contextType: "2d"

        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = "#31A8FF"
            ctx.lineWidth = 5;
            ctx.beginPath();
            ctx.moveTo(0, height / 2);
            ctx.lineTo(width, height / 2);
            ctx.stroke();

            ctx.beginPath();
            ctx.moveTo(width / 2, 0);
            ctx.lineTo(width / 2, height);
            ctx.stroke();
        }

        Connections {
            target: control
            function onPressedChanged() { canvas.requestPaint() }
            function onHoveredChanged() { canvas.requestPaint() }
        }
    }

}
