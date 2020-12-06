import QtQuick 2.15
import QtQuick.Controls 2.15

CheckBox {
    property bool elideText: false

    id: control
    text: qsTr("CheckBox")
    checked: true
    hoverEnabled: true
    implicitWidth: 80
    implicitHeight: 30

    background: Rectangle {
        width: Math.min(control.width, control.height)
        height: width
        x: control.leftPadding
        y: control.height / 2 - height / 2
        radius: 5
        color: control.enabled ? "#001E36" : "#C4C4C4"
        border.width: control.down ? 2 : control.hovered ? 1 : 0
        border.color: "#31A8FF"
    }

    indicator: Image {
        anchors.fill: control.background
        anchors.margins: control.background.width * 0.2
        source: "qrc:/check_blue.png"
        visible: control.checked
    }

    contentItem: Text {
        text: control.text
        elide: elideText ? Text.ElideRight : Text.ElideNone
        font: control.font
        opacity: control.checked || control.hovered ? 1.0 : 0.42
        color: control.checked || control.hovered ? "#31A8FF" : "#FFFFFF"
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.background.width * 1.5
        width: control.width - control.background.width
        height: control.height
    }
}
