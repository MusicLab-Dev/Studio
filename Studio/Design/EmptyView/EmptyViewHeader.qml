import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Common"

ColumnLayout {
    
    Item {
        Layout.preferredHeight: parent.height * 0.1
        Layout.preferredWidth: parent.width
    }
    
    Item {
        Layout.preferredHeight: parent.height * 0.6
        Layout.preferredWidth: parent.width
        
        Image {
            anchors.centerIn: parent
            source: "qrc:/Assets/Logo.png"
            height: parent.height
            width: parent.height
        }
    }
    
    Item {
        Layout.preferredHeight: parent.height * 0.1
        Layout.preferredWidth: parent.width
        
        Text {
            anchors.centerIn: parent
            text: "Add a new component to your workspace"
            color: "white"


            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 24
            width: parent.width
        }
    }
    
    Item {
        Layout.preferredHeight: parent.height * 0.2
        Layout.preferredWidth: parent.width
    }
}
