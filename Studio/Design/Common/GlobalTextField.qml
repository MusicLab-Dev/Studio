import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Item {
    function open(initalText, callback) {
        textInput.text = initalText
        acceptedCallback = callback
        globalTextField.visible = true
        textInput.forceActiveFocus()
        animOpen.start()
    }
    function close() {
        if (acceptedCallback) {
            acceptedCallback()
            console.debug("callback launched")
        }
        textInput.text = ""
        animClose.start()
    }

    property alias text: textInput.text;
    property var acceptedCallback: null

    id: globalTextField
    anchors.fill: parent
    visible: false

    MouseArea {
        id: ms
        anchors.fill: parent
        onReleased: { if (visible) close(); }
    }

    Rectangle {
        id: rect
        anchors.fill: parent
        opacity: 0
        color: "grey"

        OpacityAnimator {
            id: animOpen
            target: rect;
            from: 0;
            to: 0.85;
            duration: 200
            running: true
        }

        OpacityAnimator {
            id: animClose
            target: rect;
            from: 0.85;
            to: 0;
            duration: 100
            running: true

            onFinished: globalTextField.visible = false
        }
    }

    DefaultTextInput {
        id: textInput
        anchors.centerIn: parent
        width: parent.width * 0.6
        height: parent.height * 0.25
        font.pixelSize: height * 0.3
        color: "white"

        onAccepted: close()
    }
}
