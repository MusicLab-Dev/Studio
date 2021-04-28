import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property real type: 1
    property bool buttonHovered: false
    property alias text: textRoundedButtonText.text

    id: textRoundedButton
    width: 70
    height: 30
    color: type === 1 ? "transparent" : (buttonHovered ? "#31A8FF" : "#1E6FB0")
    radius: 5
    border.color: buttonHovered ? "#31A8FF" : "#1E6FB0"
    border.width: type === 1 ? 1 : 0

    Text {
        id: textRoundedButtonText
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: 10
        color: "#FFFFFF"
        opacity: type === 1 ? (textRoundedButton.buttonHovered ? 1 : 0.7) : 1
    }
}
