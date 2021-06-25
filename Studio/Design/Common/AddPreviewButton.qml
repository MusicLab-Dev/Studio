import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: control
    hoverEnabled: true

    indicator: Canvas {
        id: canvas
        anchors.centerIn: control
        width: Math.min(control.width, control.height) / 2.5
        height: width
        contextType: "2d"

        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = control.pressed ? themeManager.accentColor : control.hovered ? "#1E6FB0" : "#0D2D47"
            ctx.lineWidth = control.background.border.width / 2;
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

    background: Rectangle {
        width: control.width
        height: control.height
        border.width: 4
        border.color: control.pressed ? themeManager.accentColor : control.hovered ? "#1E6FB0" : "#0D2D47"
        radius: 8
    }
}
