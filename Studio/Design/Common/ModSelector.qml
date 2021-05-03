import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4
import "../Default"

Item {
    property var itemsPaths: []
    property var itemsNames: []
    property int itemSelected: 0
    property real widgetWidth: height / 1.5 * itemsPaths.length

    id: container

    Rectangle {
        anchors.centerIn: parent
        height: parent.height
        width: widgetWidth
        color: "transparent"
        border.color: "white"
        radius: 10

        DefaultText {
            text: itemsNames[itemSelected]
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            fontSizeMode: Text.Fit
        }

        Rectangle {
            id: rowContainer
            anchors.bottom: parent.bottom
            height: parent.height / 1.5
            width: widgetWidth
            color: "transparent"
            border.color: "white"
            radius: 10

            Repeater {
                anchors.centerIn: parent
                model: itemsPaths

                delegate: Item {
                    id: item
                    x: rowContainer.height * index
                    height: rowContainer.height
                    width: rowContainer.height

                    MouseArea{
                        anchors.fill: parent

                        onReleased: {
                            itemSelected = index
                        }
                    }

                    DefaultColoredImage {
                        height: parent.height / 2
                        width: parent.height / 2
                        anchors.centerIn: parent
                        source: itemsPaths[index]
                        color: index == itemSelected ? themeManager.accentColor : "#FFFFFF"
                    }
                }
            }

            Rectangle {
                id: cursor
                x: itemSelected * rowContainer.height
                height: rowContainer.height
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
    }
}
