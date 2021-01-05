import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Default"

Item {
    property var itemsPath: []
    property int itemSelected: 0
    readonly property real itemWidth: width / itemsPath.length

    id: container

    Rectangle {
        id: rowContainer
        anchors.verticalCenter: container.verticalCenter
        height: parent.height * 0.9
        width: parent.width
        color: "transparent"
        border.color: "white"
        radius: 10

        Repeater {
            anchors.centerIn: parent
            height: parent.height * 0.9
            width: parent.width
            model: itemsPath

            delegate: Rectangle {
                anchors.verticalCenter: rowContainer.verticalCenter
                x: itemWidth * index
                height: container.height
                width: itemWidth
                color: index == itemSelected ? "#001E36" : "transparent"
                border.color: index == itemSelected ? "white" : "transparent"
                radius: 10

                MouseArea{
                    anchors.fill: parent

                    onReleased: {
                        itemSelected = index
                    }
                }

                DefaultColoredImage {
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors.centerIn: parent
                    source: itemsPath[index]
                    color: index == itemSelected ? "blue" : "white"
                }
            }
        }
    }
}
