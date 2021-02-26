import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id: control
    leftPadding: 0
    placeholderTextColor: "lightgrey"

    background: Rectangle {
        width: parent.width
        height: 2
        y: control.height
        color: control.focus ? "#31A8FF" : "#001E36"
    }
}
