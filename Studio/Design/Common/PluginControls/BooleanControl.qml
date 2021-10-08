import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Rectangle {
    property color accentColor: themeManager.accentColor

    id: control
    width: 40
    height: 40
    radius: 8
    color: "#001E36"
    border.width: mouseArea.containsPress ? 3 : mouseArea.containsMouse ? 2 : 1
    border.color: "grey"

    DefaultToolTip { // @todo make this a unique instance
        visible: mouseArea.containsMouse
        text: controlTitle + ": " + (controlValue !== 0) + "\n" + controlDescription
        accentColor: control.accentColor
    }

    Binding {
        target: image
        property: "visible"
        value: controlValue
    }

    DefaultColoredImage {
        id: image
        anchors.centerIn: parent
        width: parent.width / 2
        height: parent.height / 2
        source: "qrc:/Assets/Checked.png"
        color: control.accentColor

        Component.onCompleted: visible = controlValue
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent

        onReleased: controlValue = !controlValue
    }
}
