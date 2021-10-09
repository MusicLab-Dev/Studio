import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Rectangle {
    color: themeManager.backgroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
        onClicked: helpHandler.open()
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
