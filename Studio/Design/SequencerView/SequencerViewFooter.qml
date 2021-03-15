import QtQuick 2.0
import QtQuick.Layouts 1.15
import "../Common"
import "../Default"

Rectangle {
    width: parent.width
    height: parent.width
    color: themeManager.foregroundColor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

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
                height: parent.height / 2
                width: parent.width / 3
            }
        }
    }
}

