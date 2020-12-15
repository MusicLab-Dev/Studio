import QtQuick 2.0
import QtQuick.Layouts 1.15

Rectangle {

    width: parent.width
    height: parent.width
    color: "#001E36"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.20

            Text {
                color: "white"
                anchors.centerIn: parent
                text: "Sequence selector"
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.10

            Text {
                color: "white"
                anchors.centerIn: parent
                text: "Toolbox"
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333


            Column {
                anchors.centerIn: parent

                Text {
                    color: "white"
                    text: "Sequencer"
                }

                Text {
                    color: "white"
                    text: "Creating sequence with Woble.wav"
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            Text {
                color: "white"
                anchors.centerIn: parent
                text: "Arrow previous/next"
            }
        }
    }
}
