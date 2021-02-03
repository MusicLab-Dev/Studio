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
            Layout.preferredWidth: parent.width * 0.4

            ModSelector {
                itemsPath: [
                    "qrc:/Assets/EditMod.png",
                    "qrc:/Assets/VelocityMod.png",
                    "qrc:/Assets/TunningMod.png",
                    "qrc:/Assets/AfterTouchMod.png",
                ]
                width: parent.width / 2
                height: parent.height / 2
                anchors.centerIn: parent
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.2
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.4

            Text {
                color: "white"
                anchors.centerIn: parent
                text: "Tempo selector"
            }
        }
    }
}

