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
            Layout.preferredWidth: parent.width * 0.333
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            Text {
                color: "white"
                anchors.centerIn: parent
                text: "play/pause/stop"
            }

        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333
        }
    }
}

