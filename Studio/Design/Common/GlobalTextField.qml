import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3

import "../Default"

Item {
    function open(initalText, callback, cancel, isColorBox, initialColor) {
        if (isColorBox)
            colorPicked = initialColor
        textInput.text = initalText
        acceptedCallback = callback
        canceledCallback = cancel
        colorBox = isColorBox
        globalTextField.visible = true
        textInput.forceActiveFocus()
        animOpen.restart()
    }

    function acceptAndClose() {
        if (acceptedCallback)
            acceptedCallback()
        textInput.text = ""
        animClose.restart()
        acceptedCallback = null
        canceledCallback = null
    }

    function cancelAndClose() {
        if (canceledCallback)
            canceledCallback()
        textInput.text = ""
        animClose.restart()
        acceptedCallback = null
        canceledCallback = null
    }

    property alias text: textInput.text;
    property alias colorPicked: colorDialog.color
    property var acceptedCallback: null
    property var canceledCallback: null
    property bool colorBox: false

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
        color: globalTextField.colorBox ? colorDialog.color : "white"

        onAccepted: acceptAndClose()
    }

    DefaultTextButton {
        anchors.left: textInput.right
        width: 50
        height: width
        visible: globalTextField.colorBox
        anchors.verticalCenter: textInput.verticalCenter
        text: qsTr("color")
        onPressed: colorDialog.open()
    }

    ColorDialog {
        id: colorDialog
        title: "Please choose a color"
        onAccepted: {
            close()
        }
        onRejected: {
            close()
        }
        Component.onCompleted: color = "white"
    }
}
