import QtQuick 2.0
import QtQuick.Layouts 1.15
import ThemeManager 1.0
import "../Default/"
import "../Common/"

RowLayout {
    spacing: 0
    
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.475
        
        DefaultImageButton {
            imgPath: "qrc:/Assets/Previous.png"
            height: parent.height / 1.5
            width: parent.height / 1.5
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            colorDefault: "white"
        }
    }
    
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.05
    }
    
    Item {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.475
        
        DefaultImageButton {
            imgPath: "qrc:/Assets/Next.png"
            height: parent.height / 1.5
            width: parent.height / 1.5
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            colorDefault: "white"
        }
    }
}
