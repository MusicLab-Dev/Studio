import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Common"

Rectangle {
    property bool tmp: true

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

            Player {
                anchors.centerIn: parent
                height: parent.height
                width: 200
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            Bpm {
                anchors.centerIn: parent
                height: parent.height * 0.8
                width: 200
            }
        }
    }
}
