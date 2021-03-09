import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Default"

Rectangle {
    id: moduleViewTab
    visible: title !== "+"
    height: parent.height * 0.05
    width: parent.width * 0.20
    x: index * parent.width * 0.20
    z: 10000
    color: componentSelected === index ? "#001E36" : "#E7E7E7"
    border.color: "black"


    MouseArea {
        anchors.fill: parent

        onClicked: {
            componentSelected = index
        }

        onPositionChanged: {
            moduleViewTab.x = mouseX + moduleViewTab.x - (moduleViewTab.width / 2)
            modules.move(index, (moduleViewTab.x / moduleViewTab.width).toFixed(), 1)
            componentSelected = index
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
            // check the case if the user wants to remove the componentSelected
            if (componentSelected === modules.count - 2)
                componentSelected = modules.count - 3
            
            // check the case if the user wants to the last component
            if (modules.count === 2) {
                modules.insert(1,
                               {
                                   title: "New component",
                                   path: "qrc:/EmptyView/EmptyView.qml",
                                   moduleZ: 0
                               })
                componentSelected = 0
            }
            modules.remove(index)
        }
    }
}
