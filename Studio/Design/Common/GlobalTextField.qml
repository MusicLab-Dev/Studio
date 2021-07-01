import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Item {
    function open(initalText, callback, cancel) {
        textInput.text = initalText
        acceptedCallback = callback
        canceledCallback = cancel
        globalTextField.visible = true
        textInput.forceActiveFocus()
        animOpen.start()
    }

    function acceptAndClose() {
        if (acceptedCallback)
            acceptedCallback()
        textInput.text = ""
        animClose.start()
        acceptedCallback = null
        canceledCallback = null
    }

    function cancelAndClose() {
        if (canceledCallback)
            canceledCallback()
        textInput.text = ""
        animClose.start()
        acceptedCallback = null
        canceledCallback = null
    }

    property alias text: textInput.text;
    property var acceptedCallback: null
    property var canceledCallback: null

    id: globalTextField
    anchors.fill: parent
    visible: false

    MouseArea {
        id: ms
        anchors.fill: parent
        onReleased: { if (visible) cancelAndClose() }
    }

    Rectangle {
        id: rect
        anchors.fill: parent
        opacity: 0
        color: "grey"

        OpacityAnimator {
            id: animOpen
            target: rect
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

        onAccepted: acceptAndClose()
    }
}
