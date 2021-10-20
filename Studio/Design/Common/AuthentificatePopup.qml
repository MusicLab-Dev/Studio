import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Default"
import "../Common"

import AudioAPI 1.0
import ActionsManager 1.0
import NodeModel 1.0
import PartitionModel 1.0

Item {
    function open() {
        openAnim.restart()
        visible = true
    }

    function close() {
        visible = false
    }

    function authentificate() {

    }

    property ActionsManager targetActionsManager: null
    property NodeModel targetNode: null
    property NodeModel targetPartitionNode: null
    property PartitionModel targetPartition: null
    property var targetInstance: undefined

    id: instanceCopyPopup
    width: parent.width
    height: parent.height
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
        color: themeManager.backgroundColor
        opacity: 0.5
    }

    DropShadow {
        id: shadow
        anchors.fill: window
        horizontalOffset: 4
        verticalOffset: 4
        radius: 6
        samples: 17
        color: "#80000000"
        source: window
    }

    MouseArea {
        id: ms
        anchors.fill: parent
        onReleased: { if (visible) close() }
    }

    ContentPopup {
        id: window
        width: 400
        height: 350

        MouseArea { // Used to prevent missclic from closing the window
            anchors.fill: parent
            onPressed: forceActiveFocus()
        }

        Item {
            id: windowArea
            anchors.fill: parent
            anchors.margins: 30

            Column {
                id: col
                width: parent.width
                spacing: 36

                DefaultText {
                    width: parent.width
                    text: qsTr("Please login with your Lexo Community account")
                    wrapMode: Text.Wrap
                    font.pixelSize: 20
                    color: "white"
                }

                DefaultTextInput {
                    id: loginField
                    width: parent.width
                    font.pixelSize: 20
                    placeholderText: qsTr("Your email address")
                }

                DefaultTextInput {
                    id: passwordField
                    width: parent.width
                    placeholderText: qsTr("Your password")
                    font.pixelSize: 20
                    echoMode: DefaultTextInput.Password
                }

                Row {
                    width: parent.width
                    height: loginField.height

                    DefaultTextButton {
                        text: qsTr("No account ? Sign-up")
                        width: parent.width - parent.height
                        height: parent.height
                        font.pixelSize: 20
                        textItem.horizontalAlignment: Qt.AlignLeft
                        textItem.fontSizeMode: Text.Fit

                        onReleased: Qt.openUrlExternally("https://community.lexostudio.com/#/signup")
                    }

                    DefaultImageButton {
                        width: parent.height
                        height: width
                        source: "qrc:/Assets/Play.png"
                        scaleFactor: 1

                        onReleased: communityAPI.authentificate(loginField.text, passwordField.text)
                    }
                }
            }
        }
    }
}
