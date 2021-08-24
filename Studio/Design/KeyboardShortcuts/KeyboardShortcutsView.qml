import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Common"

import NodeModel 1.0
import PluginTableModel 1.0
import KeyboardEventListener 1.0

Item {
    function open() {
        visible = true
        openAnim.start()
    }

    function close() {
        visible = false
    }

    function reset() {
         eventDispatcher.keyboardListener.resetShortcuts()
    }

    id: keyboardShortcutsView
    visible: false

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

    ContentPopup {
        id: window

        Text {
            id: title
            x: parent.width / 2 - width / 2
            y: height
            text: qsTr("Keyboard shortcuts")
            color: "lightgrey"
            font.pointSize: 34
        }

        TextRoundedButton {
            id: closeButton
            text: qsTr("Close")
            anchors.top: window.top
            anchors.topMargin: 30
            anchors.right: window.right
            anchors.rightMargin: 30

            onReleased: keyboardShortcutsView.close()
        }

        TextRoundedButton {
            text: qsTr("Reset")
            anchors.top: window.top
            anchors.topMargin: 30
            anchors.right: closeButton.left
            anchors.rightMargin: 30

            onReleased: keyboardShortcutsView.reset()
        }

        KeyboardShortcutsContent {
            id: keyboardShortcutsContent
            anchors.top: title.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 50
        }
    }

    KeySequencePopup {
        id: keySequencePopup
        anchors.fill: parent
    }
}
