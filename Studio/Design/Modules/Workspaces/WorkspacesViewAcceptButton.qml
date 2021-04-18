import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    property bool acceptButtonHovered: false

    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: "Accept"
    font.pointSize: 10
    color: "#FFFFFF"
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    opacity: acceptButtonHovered ? 1 : 0.7

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: { acceptButtonHovered = true }

        onExited: { acceptButtonHovered = false }

        onReleased: { workspaceView.cancelAndaccept() }
    }
}
