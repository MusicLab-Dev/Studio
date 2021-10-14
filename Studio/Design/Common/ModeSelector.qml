import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4
import "../Default"
import "../Sequencer"

Item {
    // properties
    property var itemsPaths: []
    property var itemsNames: []
    property int itemSelected: 0
    property int itemUsableTill: 0

    // alias
    default property alias placeholder: placeholder.data
    property alias rowContainer: rowContainer

    //optimisation
    property real itemWidth: rowContainer.width / itemsPaths.length

    id: container

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "white"
        radius: 6

        Item {
            id: placeholder
            anchors.fill: parent
        }

        DefaultText {
            text: itemsNames[itemSelected]
            y: parent.height * 0.3 / 2 - height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            fontSizeMode: Text.Fit
        }

        Rectangle {
            id: rowContainer
            anchors.bottom: parent.bottom
            height: parent.height * 0.7
            width: parent.width
            color: "transparent"
            border.color: "white"
            radius: 6

            Repeater {
                model: itemsPaths

                delegate: Item {
                    id: item
                    x: itemWidth * index
                    height: rowContainer.height
                    width: itemWidth

                    DefaultImageButton {
                        height: parent.height / 2
                        width: parent.height / 2
                        anchors.centerIn: parent
                        source: itemsPaths[index]
                        colorDefault: index > itemUsableTill ? themeManager.disabledColor : index == itemSelected ? themeManager.accentColor : "white"
                        scaleFactor: 1
                        showBorder: false

                        onReleased: {
                            if (index <= itemUsableTill)
                                itemSelected = index
                        }
                    }
                }
            }

            Rectangle {
                id: cursor
                x: itemSelected * itemWidth
                height: rowContainer.height
                width: itemWidth
                border.color: "white"
                color: "transparent"
                radius: 6

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
