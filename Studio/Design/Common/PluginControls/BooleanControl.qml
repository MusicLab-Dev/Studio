import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Rectangle {
    id: control
    width: 30
    height: 30
    radius: 5
    color: "#001E36"
    border.width: mouseArea.containsPress ? 3 : mouseArea.containsMouse ? 2 : 1
    border.color: "grey"

    ToolTip.visible: mouseArea.containsMouse
    ToolTip.text: controlTitle + ": " + (controlValue !== 0) + "\n" + controlDescription

    Image {
        anchors.centerIn: parent
        width: parent.width / 2
        height: parent.height / 2
        source: "qrc:/Assets/Checked.png"
        visible: controlValue
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent

        onReleased: controlValue = !controlValue
    }
}