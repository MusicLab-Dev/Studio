import QtQuick 2.15
import QtQuick.Controls 2.15

Text {
    property bool closeButtonHovered: false

    text: "Close"
    font.pointSize: 14
    font.weight: Font.DemiBold
    color: closeButtonHovered ? "#31A8FF" : "#FFFFFF"
    opacity: closeButtonHovered ? 1 : 0.7

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: { closeButtonHovered = true }

        onExited: { closeButtonHovered = false }

        onReleased: { pluginsView.cancelAndClose() }
    }
}
