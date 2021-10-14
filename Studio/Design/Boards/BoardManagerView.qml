import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Rectangle {
    id: boardContentView
    color: themeManager.backgroundColor

    GridView {
        id: boardsPreview
        width: parent.width
        height: parent.height
        cellWidth: boardContentView.width / 3
        cellHeight: cellWidth / 2

        model: boardManager

        delegate: Item {
            width: boardsPreview.cellWidth
            height: boardsPreview.cellHeight

            Rectangle {
                property real boardWidth: boardSize.width
                property real boardHeight: boardSize.height
                property real unitSize: (Math.min(width, height) * 0.92) / Math.max(boardWidth, boardHeight)

                id: boardPreviewSlot
                x: index * width
                anchors.fill: parent
                anchors.margins: parent.width * 0.02
                color: "white"
                border.width: boardManagerMouseArea.containsMouse ? 5 : 0
                border.color: themeManager.accentColor
                radius: 6

                Rectangle {
                    id: boardPreview
                    width: boardPreviewSlot.unitSize * boardPreviewSlot.boardWidth
                    height: boardPreviewSlot.unitSize * boardPreviewSlot.boardHeight
                    x: parent.width / 2 - width / 2
                    y: parent.height / 2 - height / 2
                    anchors.margins: parent.width * 0.02
                    color: boardManagerMouseArea.containsMouse ? themeManager.accentColor : themeManager.foregroundColor
                    radius: 6

                    DefaultText {
                        anchors.centerIn: parent
                        text: boardPreviewSlot.boardWidth + " x " + boardPreviewSlot.boardHeight
                        font.pixelSize: 40
                        font.bold: true
                        color: boardManagerMouseArea.containsMouse ? "black" : "white"
                    }
                }

                MouseArea {
                    id: boardManagerMouseArea
                    hoverEnabled: true
                    anchors.fill: parent

                    onClicked: {
                        boardControlsView.open(boardInstance.instance)
                    }
                }
            }
        }
    }
}
