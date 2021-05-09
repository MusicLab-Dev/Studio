import QtQuick 2.15
import QtQuick.Controls 2.15

import Board 1.0

import "../Default"

Rectangle {
    function open(boardInstance) {
        board = boardInstance
        visible = true
    }

    function close() {
        board = null
        visible = false
    }

    property Board board: null
    property int boardWidth: board ? board.size.width : 0
    property int boardHeight: board ? board.size.height : 0
    property real unitSize: (Math.min(width, height) * 0.98) / Math.max(boardWidth, boardHeight)

    id: boardContentView
    color: themeManager.foregroundColor
    visible: false
    radius: 13

    DefaultMenu {
        property int targetInput: 0
        id: assignMenu

        Repeater {
            model: eventDispatcher.targetEventList

            delegate: MenuItem {
                text: modelData

                onTriggered: eventDispatcher.boardListener.add(board.boardID, targetInput, index)
            }
        }
    }

    Grid {
        property real cellWidth: width / boardWidth
        property real cellHeight: height / boardHeight

        id: boardGrid
        width: unitSize * boardWidth
        height: unitSize * boardHeight
        columns: boardWidth
        anchors.centerIn: parent

        Repeater {
            model: boardWidth * boardHeight

            delegate: Item {
                width: boardGrid.cellWidth
                height: boardGrid.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: parent.width * 0.02
                    color: "white"
                    radius: 10
                }
            }
        }
    }

    Item {
        anchors.fill: boardGrid

        Repeater {
            model: board

            delegate: DefaultImageButton {
                x: controlPos.x * boardGrid.cellWidth
                y: controlPos.y * boardGrid.cellHeight
                width: boardGrid.cellWidth
                height: boardGrid.cellHeight
                source: controlType === Board.ControlType.Button ? "qrc:/Assets/BoardButton.png" : controlType === Board.ControlType.Potentiometer ? "qrc:/Assets/BoardPotentiometer.png" : ""

                onReleased: {
                    assignMenu.targetInput = index
                    assignMenu.open()
                }
            }
        }
    }
}
