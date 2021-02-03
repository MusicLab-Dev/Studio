import QtQuick 2.0
import QtQuick.Layouts 1.15
import "../Default"
import "../Common"

Rectangle {
    width: parent.width
    height: parent.width
    color: "#001E36"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.4
        }


        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.2
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.4
        }
    }
}

