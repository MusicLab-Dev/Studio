import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Help"

Item {
    function open()
    {
        openAnim.start()
    }

    property real opacityMax: 0.7

    MouseArea {
        anchors.fill: textButton
        onPressedChanged: forceActiveFocus()
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

    DefaultTextButton {
        text: "?"
        onReleased: helpHandler.open()
        width: 50
        height: 50
    }
}
