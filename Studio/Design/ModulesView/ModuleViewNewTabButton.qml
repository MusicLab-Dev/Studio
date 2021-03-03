import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Default"

Rectangle {
    property real barSize: width / 4

    id: newTabButton
    visible: title === "+"
    height: parent.height * 0.05
    width: parent.height * 0.05
    x: index * parent.width * 0.20
    color: "#001E36"
    border.color: "black"
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            modules.insert(
                        modulesViewContent.modules.count - 1,
                        {title: "New component",
                            path: "qrc:/EmptyView/EmptyView.qml",
                            moduleZ: modulesViewContent.modules.count
                        })
            modulesViewContent.componentSelected = modulesViewContent.modules.count - 2
        }
    }
    
    Rectangle {
        width: barSize
        height: barSize / 8
        anchors.centerIn: parent
        radius: 20
    }
    
    Rectangle {
        width: barSize / 8
        height: barSize
        anchors.centerIn: parent
        radius: 20
    }
}
