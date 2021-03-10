import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Default"

Rectangle {
    id: moduleViewTab
    color: componentSelected === index ? "#001E36" : "#E7E7E7"
    border.color: "black"


    MouseArea {
        anchors.fill: parent

        onClicked: {
            componentSelected = index
        }

        onPositionChanged: {
            moduleViewTab.x = mouseX + moduleViewTab.x - (moduleViewTab.width / 2)
            var position = (moduleViewTab.x / moduleViewTab.width).toFixed()
            if (index !== position) {
                modules.move(index, position, 1)
                componentSelected = index
            }
        }

        onReleased: {
            moduleViewTab.x = index * moduleViewTab.width
        }
    }
    
    Text {
        anchors.centerIn: parent
        text: title
        color: componentSelected === index ? "white" : "black"
    }
    
    DefaultImageButton {
        imgPath: "qrc:/Assets/Close.png"
        height: parent.height / 2
        width: parent.height / 2
        anchors.top: parent.top
        anchors.right: parent.right
        colorDefault: "red"
        showBorder: false
        visible: !(modules.count === 2 && title === "New component")
        
        onClicked: {
            if (componentSelected === modules.count - 2)
                componentSelected = modules.count - 3
            if (modules.count === 2) {
                modules.insert(1,
                               {
                                   title: "New component",
                                   path: "qrc:/EmptyView/EmptyView.qml",
                               })
                componentSelected = 0
            }
            modules.remove(index)
        }
    }
}
