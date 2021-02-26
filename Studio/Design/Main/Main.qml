import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import BoardManager 1.0

import "../Default"

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("MusicLab")

    BoardManager {
        id: boardManager
    }

    Column {
        id: settignsCol
        anchors.left: parent.left

        Row {
            Text {
                text: "Tick rate: " + boardManager.tickRate
            }

            Slider {
                id: tickRateSlider
                from: 0
                to: 5000
                stepSize: 1
                value: boardManager.tickRate

                onMoved: boardManager.tickRate = value
            }
        }

        Row {
            Text {
                text: "Discover rate: " + boardManager.discoverRate
            }

            Slider {
                id: discoverRateSlider
                from: 0
                to: 5000
                stepSize: 1
                value: boardManager.discoverRate

                onMoved: boardManager.discoverRate = value
            }
        }
    }

    Rectangle {
        anchors.fill:parent
        anchors.leftMargin: settignsCol.width
        color: "transparent"
        border.width: 1
        border.color: "black"

        ListView {
            anchors.fill: parent
            anchors.margins: 5

            spacing: 10
            model: boardManager

            delegate: Rectangle {
                color: "red"
                width: 5 +  boardSize.width * 10
                height: 5 + boardSize.height * 10

                ListView {
                    anchors.fill: parent
                    anchors.margins: 5

                    spacing: 2
                    model: boardInstance

                    delegate: Rectangle {
                        width: 10
                        height: 10
                        color: "yellow"
                    }
                }
            }
        }
    }
}
