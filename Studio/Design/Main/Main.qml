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
        anchors.centerIn: parent

        Button {
            text: "Click me"

            onReleased: boardManager.foo()
        }

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
}
