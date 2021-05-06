import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    readonly property bool cancelKeyboardEventsOnFocus: true

    id: control
    leftPadding: 0
    placeholderTextColor: "lightgrey"

    onAccepted: focus = false

    background: Rectangle {
        width: parent.width
        height: 2
        y: control.height
        color: control.focus ? "#31A8FF" : "#001E36"
    }
}
