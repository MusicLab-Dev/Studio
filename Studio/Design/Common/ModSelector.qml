import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Default"

Item {
    property bool smallVersion: false
    property var itemsPath: []
    property int itemSelected: 0

    id: container

    Rectangle {
        id: rowContainer
        visible: !smallVersion
        anchors.centerIn: parent
        height: parent.height
        width: parent.height * itemsPath.length
        color: "transparent"
        border.color: "white"
        radius: 10

        Repeater {
            anchors.centerIn: parent
            model: itemsPath

            delegate: Item {
                id: item
                x: parent.height * index
                height: container.height
                width: parent.height

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
                    color: index == itemSelected ? themeManager.accentColor : "#FFFFFF"
                }
            }
        }

        Rectangle {
            id: cursor
            x: itemSelected * width
            height: container.height
            width: parent.height
            border.color: "white"
            color: "transparent"
            radius: 10

            Behavior on x {
                SpringAnimation {
                    spring: 2
                    damping: 0.3
                    duration: 400
                }
            }
        }
    }

    Rectangle {
        visible: smallVersion
        height: parent.height
        width: parent.width
        color: "transparent"
        border.color: "white"

        MouseArea{
            anchors.fill: parent

            onReleased: {
                if (itemSelected === itemsPath.length - 1)
                    itemSelected = 0
                else
                    itemSelected += 1
            }
        }

        DefaultColoredImage {
            height: parent.height / 2
            width: height
            anchors.centerIn: parent
            source: itemsPath[itemSelected]
            color: "#FFFFFF"
        }
    }
}
