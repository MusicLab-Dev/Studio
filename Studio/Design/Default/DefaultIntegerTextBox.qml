import QtQuick 2.15
import QtQuick.Controls 2.15

DefaultTextInput {
    property int bottomRange: 0
    property int topRange: 1000000

    id: control
    width: parent.width
    height: parent.height
    leftPadding: height * 0.3
    placeholderText: qsTr("Enter number(s)")
    placeholderTextColor: control.hovered || control.focus ? themeManager.accentColor : "#295F8B"
    hoverEnabled: true
    color: control.hovered || control.focus ? themeManager.accentColor : "#295F8B"

    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: control.hovered || control.focus ? themeManager.accentColor : "#295F8B"
    }

    validator: IntValidator {
        id: validator
        bottom: control.bottomRange
        top: control.topRange
    }
}
