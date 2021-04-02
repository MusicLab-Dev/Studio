import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Common"
import "../Default"

RowLayout {
    spacing: 0

    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333

        DefaultImageButton {
            source: "qrc:/Assets/Replay.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            colorDefault: "white"

            onReleased: {
                app.scheduler.pause()
            }
        }
    }
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333

        DefaultImageButton {
            source: "qrc:/Assets/Play.png"
            height: parent.height / 1.5
            width: parent.height / 1.5
            anchors.centerIn: parent
            colorDefault: "white"

            onReleased: {
                app.scheduler.play()
            }
        }
    }
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333

        DefaultImageButton {
            source: "qrc:/Assets/Stop.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            colorDefault: "white"

            onReleased: {
                app.scheduler.stop()
            }
        }
    }
}
