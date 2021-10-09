import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Default"
import "../Common"

Item {
    function open(accepted, canceled) {
        key = 0
        modifiers = 0
        acceptedCallback = accepted
        canceledCallback = canceled
        openAnim.restart()
        visible = true
        eventDispatcher.keyboardListener.detection = true
    }

    function acceptAndClose() {
        visible = false
        if (acceptedCallback)
            acceptedCallback()
        close()
    }

    function cancelAndClose() {
        visible = false
        if (canceledCallback)
            canceledCallback()
        close()
    }

    function close() {
        key = 0
        modifiers = 0
        acceptedCallback = null
        canceledCallback = null
        eventDispatcher.keyboardListener.detection = false
    }

    property var acceptedCallback: null
    property var canceledCallback: null
    property int key: 0
    property int modifiers: 0

    id: keySequencePopup
    width: parent.width
    height: parent.height
    visible: false

    Connections {
        target: eventDispatcher.keyboardListener
        enabled: keySequencePopup.visible

        function onKeyPressDetected(targetKey, targetModifiers) {
            key = targetKey
            modifiers = targetModifiers
        }
    }

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: window; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: shadow; property: "opacity"; from: 0.1; to: 1; duration: 500; easing.type: Easing.Linear }
        PropertyAnimation { target: background; property: "opacity"; from: 0.1; to: 0.5; duration: 300; easing.type: Easing.Linear }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "grey"
        opacity: 0.5
    }

    DropShadow {
        id: shadow
        anchors.fill: window
        horizontalOffset: 4
        verticalOffset: 4
        radius: 8
        samples: 17
        color: themeManager.popupDropShadow
        source: window
    }

    MouseArea {
        id: ms
        anchors.fill: parent
        onReleased: { if (visible && !exporting) close() }
    }

    ContentPopup {
        id: window
        width: Math.max(parent.width * 0.3, 400)
        height: windowCol.height + 2 * windowArea.anchors.margins

        MouseArea { // Used to prevent missclic from closing the window
            anchors.fill: parent
            onPressed: forceActiveFocus()
        }

        Item {
            id: windowArea
            anchors.fill: parent
            anchors.margins: 30

            Column {
                id: windowCol
                width: windowArea.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                DefaultText {
                    text: qsTr("Press desired key combination and press 'Yes'")
                    width: windowArea.width
                    height: 30
                    wrapMode: Text.Wrap
                    font.pixelSize: 20
                    fontSizeMode: Text.Fit
                    color: "white"
                }

                DefaultText {
                    id: keySequence
                    topPadding: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: windowArea.width
                    height: noButton.height * 2
                    font.pixelSize: 16
                    color: "white"
                    text: {
                        if (key === 0)
                            return qsTr("Undefined")
                        else
                            return eventDispatcher.keyboardListener.keyToString(key, modifiers)
                    }
                }

                Row {
                    id: confirmRow
                    topPadding: 15
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: noButton.height
                    spacing: 30

                    TextRoundedButton {
                        text: qsTr("Yes")
                        hoverOnText: false

                        onReleased: keySequencePopup.acceptAndClose()
                    }

                    TextRoundedButton {
                        id: noButton
                        text: qsTr("No")

                        onReleased: keySequencePopup.cancelAndClose()
                    }
                }
            }
        }
    }
}
