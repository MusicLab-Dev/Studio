import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Common"
import "../Default"

Rectangle {

    width: parent.width
    height: parent.width
    color: "#001E36"

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
