import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Item {
    function open(initalText, acceptedCallback) {
        textInput.text = initalText
        globalTextField.visible = true
        textInput.forceActiveFocus()
    }
    function close() {
        if (acceptedCallback)
            acceptedCallback(textInput.text)
        textInput.text = ""
        globalTextField.visible = false
    }

    property var acceptedCallback: null

    id: globalTextField
    anchors.fill: parent
    visible: true

    MouseArea {
        id: ms
        anchors.fill: parent
        onReleased: close()
    }

    Rectangle {
        anchors.fill: parent
        opacity: 0.75
        color: "grey"
    }

    DefaultTextInput {
        id: textInput
        anchors.centerIn: parent
        width: parent.width * 0.75
        height: parent.height / 4
        font.pixelSize: height * 0.5
        color: "white"

        onAccepted: close()
    }
}