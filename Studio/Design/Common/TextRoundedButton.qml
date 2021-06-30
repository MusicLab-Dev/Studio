import QtQuick 2.15
import QtQuick.Controls 2.15


MouseArea {
    property bool hoverOnText: true
    property bool containsMouse: false
    property alias text: textRoundedButtonText.text

    id: textRoundedButton
    width: 70
    height: 30
    hoverEnabled: true

    Rectangle {
        anchors.fill: parent
        color: textRoundedButton.hoverOnText ? "transparent" : (textRoundedButton.containsMouse ? themeManager.accentColor : "#1E6FB0")
        radius: 5
        border.color: textRoundedButton.containsMouse ? themeManager.accentColor : "#1E6FB0"
        border.width: textRoundedButton.hoverOnText ? 1 : 0

        Text {
            id: textRoundedButtonText
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 10
            color: "#FFFFFF"
            opacity: textRoundedButton.hoverOnText ? (textRoundedButton.containsMouse ? 1 : 0.7) : 1
        }
    }

}