import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Item {
    property real opacityMax: 0.7

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
        onClicked: helpHandler.open()
    }

    Rectangle {
        anchors.fill: parent
        color: themeManager.foregroundColor
        opacity: opacityMax
    }

    DefaultTextButton {
        id: textButton
        anchors.centerIn: parent
        width: parent.width * 0.2
        height: parent.height * 0.5
        text: app.project.name + "'s tree"
        font.pixelSize: 35

        onReleased: {
            globalTextField.open(
                app.project.name,
                function() { app.project.name = globalTextField.text },
                function () {},
                false,
                null
            );
        }
    }
}
