import QtQuick 2.0
import QtQuick.Layouts 1.15
import "../Common"
import "../Default"

RowLayout {
    anchors.fill: parent
    spacing: 0
    
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333
        
        DefaultImageButton {
            imgPath: "qrc:/Assets/Replay.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            colorDefault: "white"
        }
    }
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333
        
        DefaultImageButton {
            imgPath: "qrc:/Assets/Play.png"
            height: parent.height / 1.5
            width: parent.height / 1.5
            anchors.centerIn: parent
            colorDefault: "white"
        }
    }
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.333
        
        DefaultImageButton {
            imgPath: "qrc:/Assets/Stop.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            colorDefault: "white"
        }
    }
}
