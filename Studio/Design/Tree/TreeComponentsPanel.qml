import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../Default"

Item {
    function open() {
        launched = true
        openAnim.start()
    }

    function close() {
        launched = false
        closeAnim.start()
    }

    property bool launched: false
    property real durationAnimation: 300

    id: treeComponentsPanel

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: panel; property: "x"; to: width - panel.width; duration: durationAnimation; easing.type: Easing.OutCubic }
        PropertyAnimation { target: buttonPanel; property: "opacity"; to: 0; duration: durationAnimation; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: closeAnim
        PropertyAnimation { target: panel; property: "x"; to: width; duration: durationAnimation; easing.type: Easing.OutCubic }
        PropertyAnimation { target: buttonPanel; property: "opacity"; to: 0.6; duration: durationAnimation; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: buttonPanel

        anchors.right: panel.left
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.topMargin: parent.height / 2 - height / 2

        width: parent.width * 0.04
        height: width
        opacity: 0.6
        color: "black"

        Image {
            id: plus
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: parent.height * 0.6
            source: "qrc:/Assets/Plus.png"
        }

        ColorOverlay {
                anchors.fill: plus
                source: plus
                color: "white"
            }

        MouseArea {
            anchors.fill: parent

            onPressed: {
                open()
            }

        }

    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter

        id: panel
        x: parent.width
        width: parent.width * 0.15
        height: parent.height * 0.9

        opacity: 0.6
        color: "black"

        ColumnLayout {
            anchors.centerIn: parent
            height: parent.height * 0.9
            width: parent.width * 0.9

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TreeComponent {
                    text.text: "Mixer"
                }

            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TreeComponent {
                    text.text: "Source"
                }

            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TreeComponent {
                    text.text: "Effect"
                }

            }

        }
    }

}
