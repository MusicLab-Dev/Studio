import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    property bool closeButtonHovered: false

    anchors.fill: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: "Close"
    font.pointSize: 10
    color: "#FFFFFF"
    opacity: closeButtonHovered ? 1 : 0.7

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: { closeButtonHovered = true }

        onExited: { closeButtonHovered = false }

        onReleased: { pluginsView.cancelAndClose() }
    }
}
