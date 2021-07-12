import QtQuick 2.0
import QtQuick.Layouts 1.3

import "../Default"

Item {

    function open() {
        openPanel.start()
    }

    function close() {
        closePanel.start()
    }

    property bool launched: false
    property real durationAnimation: 200

    id: treeComponentsPanel

    PropertyAnimation { id: openPanel; target: panel; property: "x"; to: width - panel.width; duration: durationAnimation; easing.type: Easing.OutCubic }
    PropertyAnimation { id: closePanel; target: panel; property: "x"; to: width; duration: durationAnimation; easing.type: Easing.OutCubic }

    Rectangle {
        id: buttonPanel

        anchors.right: panel.left
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.05

        width: parent.width * 0.03
        height: width

        color: "black"

        MouseArea {
            anchors.fill: parent

            onPressed: {
                launched = !launched
                if (launched)
                    open()
                else
                    close()
            }

        }

    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter

        id: panel
        x: parent.width
        width: parent.width * 0.15
        height: parent.height * 0.9
        opacity: 0.5

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

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.7
                    height: parent.height * 0.7

                    DefaultText {
                        anchors.fill: parent
                        text: "Source"
                    }

                    MouseArea {
                        anchors.fill: parent

                        onPressed: {
                            close()
                        }
                    }

                }

            }


        }
    }

}
