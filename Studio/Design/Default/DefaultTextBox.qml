import QtQuick 2.15
import QtQuick.Controls 2.15

DefaultTextInput {
    id: control
    width: parent.width
    height: parent.height
    leftPadding: height * 0.3
    placeholderText: qsTr("Enter some text")
    placeholderTextColor: color
    hoverEnabled: true
    color: control.hovered || control.focus ? "#31A8FF" : "#295F8B"

    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: control.hovered || control.focus ? "#31A8FF" : "#295F8B"
    }
}
