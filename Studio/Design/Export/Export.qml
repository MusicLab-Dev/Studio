import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Common"
import "ExportDelegates"

Item {
    function open() {
        visible = true
        inProcess = false
        openOpacity.start()
    }

    function close() {
        closeOpacity.start()
    }

    function launch() {

    }

    function stop() {

    }

    property bool inProcess: false

    id: exportWindow

    visible: false

    Rectangle {
        id: exportPopup
        anchors.centerIn: parent

        width: parent.width * 0.6
        height: parent.height * 0.5
        color: "grey"
        opacity: 0

        OpacityAnimator on opacity{
                id: openOpacity
                from: 0;
                to: 1;
                duration: 100
            }

        OpacityAnimator on opacity{
                id: closeOpacity
                from: 1;
                to: 0;
                duration: 100
                onFinished: exportWindow.visible = false
            }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.1
                id: title

                DefaultText {

                    anchors.fill: parent

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text: qsTr("Export")
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: options

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    ExportComboBox {
                        Layout.preferredHeight: parent.height * 0.15
                        Layout.fillWidth: true

                        text.text: qsTr("Type")

                        comboBox.model: ListModel {
                            ListElement { text: "16" }
                            ListElement { text: "24" }
                            ListElement { text: "32" }
                        }
                        comboBox.height: exportPopup.height * 0.1
                        comboBox.width: width * 0.4

                    }

                    ExportComboBox {
                        Layout.preferredHeight: parent.height * 0.15
                        Layout.fillWidth: true

                        text.text: "Hz"

                        comboBox.model: ListModel {
                            ListElement { text: "44100" }
                            ListElement { text: "88200" }
                        }
                        comboBox.height: exportPopup.height * 0.1
                        comboBox.width: width * 0.4

                    }

                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.1

                id: progressBar

                visible: inProcess

            }

            Item {

                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.15
                id: buttons

                RowLayout {
                    anchors.centerIn: parent
                    width: parent.width * 0.95
                    height: parent.height
                    spacing: 10

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.preferredHeight: parent.height * 0.8
                        Layout.preferredWidth: parent.width * 0.2

                        TextRoundedButton {
                            anchors.fill: parent

                            text: inProcess ? qsTr("Abort") : qsTr("Launch")

                            onClicked: {
                                inProcess = !inProcess
                                if (inProcess)
                                    launch()
                                else
                                    stop()
                            }
                        }

                    }

                    Item {
                        Layout.preferredHeight: parent.height * 0.8
                        Layout.preferredWidth: parent.width * 0.2

                        TextRoundedButton {
                            anchors.fill: parent

                            text: qsTr("Close")

                            onClicked: {
                                stop()
                                close()
                            }
                        }

                    }
                }
            }

        }

    }

}
