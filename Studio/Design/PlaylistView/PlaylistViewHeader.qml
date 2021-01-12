import QtQuick 2.0
import QtQuick.Layouts 1.15
import "../Common"
import "../Default"

Rectangle {

    width: parent.width
    height: parent.width
    color: "#001E36"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            ModSelector {
                itemsPath: [
                    "qrc:/Assets/NormalMod.png",
                    "qrc:/Assets/SelectorMod.png",
                    "qrc:/Assets/CutMod.png",
                ]
                width: parent.width / 4
                height: parent.height / 2
                anchors.centerIn: parent
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
                        text: "Playlist"
                    }
                }
                Text {
                    color: "white"
                    text: "Bring musical sequences together"
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.15
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.15

            ArrowNextPrev {}
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width
        }
    }
}
