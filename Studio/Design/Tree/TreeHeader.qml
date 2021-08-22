import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Rectangle {
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    DefaultTextButton {
        anchors.fill: parent
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
}
