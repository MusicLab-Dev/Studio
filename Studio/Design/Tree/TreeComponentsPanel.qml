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
        PropertyAnimation { target: panel; property: "x"; to: (width - panel.width) - 32; duration: durationAnimation; easing.type: Easing.OutCubic }
        PropertyAnimation { target: panel; property: "opacity"; from: 0; to: 1; duration: durationAnimation; easing.type: Easing.OutCubic }
        PropertyAnimation { target: buttonPanel; property: "opacity"; to: 0; duration: durationAnimation; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: closeAnim
        PropertyAnimation { target: panel; property: "x"; to: width; duration: durationAnimation; easing.type: Easing.OutCubic }
        PropertyAnimation { target: panel; property: "opacity"; from: 1; to: 0; duration: durationAnimation; easing.type: Easing.OutCubic }
        PropertyAnimation { target: buttonPanel; property: "opacity"; to: 0.7; duration: durationAnimation; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: buttonPanel

        anchors.right: panel.left
        anchors.rightMargin: 32
        anchors.top: parent.top
        anchors.topMargin: parent.height / 2 - height / 2

        width: parent.width * 0.04
        height: width
        opacity: 0.7
        color: themeManager.foregroundColor
        radius: 1000

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

    Item {
        id: panel
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.15
        height: parent.height * 0.9
        x: parent.width

        Rectangle {

            id: panelBackground
            anchors.fill: parent
            radius: 32
            color: themeManager.foregroundColor
            opacity: 0.7
        }

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
