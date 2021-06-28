import QtQuick 2.15
import QtQuick.Controls 2.15

DefaultTextInput {
    property real bottomRange: 0.0
    property real topRange: 1000000.0

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

    validator: DoubleValidator {
        id: validator
        bottom: control.bottomRange
        top: control.topRange
    }
}
