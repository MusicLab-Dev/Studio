import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Help"

Rectangle {
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: textButton
        onPressedChanged: forceActiveFocus()
    }

    DefaultTextButton {
        id: textButton
        anchors.centerIn: parent
        width: parent.width * 0.3
        height: parent.height
        text: app.project.name
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

    DefaultTextButton {
        text: "?"
        onReleased: helpHandler.open()
        width: 50
        height: 50
    }
}
