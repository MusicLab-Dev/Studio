import QtQuick 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0
import "../Default/"
import "../Common/"

Rectangle {
    color: "#001E36"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.5

                    DefaultComboBox {
                        width: parent.width / 2
                        height: parent.height / 2
                        anchors.centerIn: parent
                        model: [
                            "Sequence1",
                            "Sequence2",
                            "Sequence3"
                        ]
                    }
                }

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.5

                    ModSelector {
                        itemsPath: [
                            "qrc:/Assets/NormalMod.png",
                            "qrc:/Assets/BrushMod.png",
                            "qrc:/Assets/SelectorMod.png",
                            "qrc:/Assets/CutMod.png",
                        ]
                        width: parent.width / 2
                        height: parent.height / 2
                        anchors.centerIn: parent
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333


            ColumnLayout {
                anchors.centerIn: parent

                Item {
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width

                    Text {
                        anchors.centerIn: parent
                        color: "white"
                        text: "Sequencer"
                    }
                }

                Text {
                    color: "white"
                    text: "Creating sequence with Woble.wav"
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.2
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.133

            ArrowNextPrev {
                anchors.fill: parent
            }
        }
    }
}
