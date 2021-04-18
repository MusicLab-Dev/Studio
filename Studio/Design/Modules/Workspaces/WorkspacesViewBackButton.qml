import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    property bool backButtonHovered: false

    visible: workspaceForeground.parentDepth !== 0
    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: "Back"
    font.pointSize: 10
    color: "#FFFFFF"
    opacity: backButtonHovered ? 1 : 0.7

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: { backButtonHovered = true }

        onExited: { backButtonHovered = false }

        onReleased: {
            workspaceForeground.actualPath += "/.."
            workspaceForeground.parentDepth -= 1
        }
    }
}
