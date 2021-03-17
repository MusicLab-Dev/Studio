import QtQuick 2.15
import QtQuick.Controls 2.15

BoardBackground {
    id: boardViewBackground
    color: "#001E36"
    radius: 30

    BoardViewTitle {
        id: boardViewTitle
        width: parent.width
    }

    Rectangle {
            id: boardContentView
            //color: "#4A8693"
            color: "#4A8693"
            anchors.top: boardViewTitle.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: parent.width * 0.02
            radius: 13

            GridView {
                id: boardGrid
                width: parent.width
                height: parent.height
                cellWidth: boardContentView.width / 5
                cellHeight: cellWidth / 3

                model: 35
                delegate: Item {
                    width: boardGrid.cellWidth
                    height: boardGrid.cellHeight

                    Rectangle {
                        x: index * width
                        anchors.fill: parent
                        anchors.margins: parent.width * 0.02
                        color: "white"
                        radius: 10
                    }
                }
            }
    }
    /*Rectangle {
        id: boardContentView
        //color: "#4A8693"
        color: "#001E36"
        anchors.top: boardViewTitle.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.width * 0.02
        radius: 13

        GridView {
            id: boardsPreview
            width: parent.width
            height: parent.height
            cellWidth: boardContentView.width / 3
            cellHeight: cellWidth / 2

            model: 4
            delegate: Item {
                width: boardsPreview.cellWidth
                height: boardsPreview.cellHeight

                Rectangle {
                    property real boardWidth: 8
                    property real boardHeight: 8

                    id: boardPreviewSlot
                    x: index * width
                    anchors.fill: parent
                    anchors.margins: parent.width * 0.02
                    color: "white"
                    radius: 10

                    Rectangle {
                        id: boardPreview
                        width: (parent.width * 0.92) * (boardPreviewSlot.boardWidth / 8)
                        height: (parent.height - (parent.width - parent.width * 0.92)) * (boardPreviewSlot.boardHeight / 8)
                        x: parent.width / 2 - width / 2
                        y: parent.height / 2 - height / 2
                        anchors.margins: parent.width * 0.02
                        color: "#4A8693"
                        radius: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {}
                    }
                }
            }
        }*/

        /*GridView {
            id: gridView

            model: ListModel {
                ListElement {
                    boardWidth: 12
                    boardHeight: 8
                }
            }

            //ListModel {
            //  ListElement {
            //      type: 0
            //      state: 0
            //      pos: Qt.point(1, 1)
            //  }
            //  ListElement {
            //      type: 0
            //      state: 1
            //      pos: Qt.point(2, 3)
            //  }
            //}

            delegate: Rectangle {
                width: gridView.width / 4
                height: gridView.height / 4
                color: "red"
            }
        }*/

        /*BubblePopup {
            id: bubblePopup
            anchors.fill: parent
        }

        Rectangle {
            id: btn
            width: 120
            height: 70
            radius: 15
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            color: "white"

            MouseArea {
                width: parent.width
                height: parent.height

                onReleased: {
                    btn.color = "black"
                    boardContentView.color = "#4A8693"
                    boardContentView.opacity = 1
                    bubblePopup.visible = !bubblePopup.visible
                }
            }
        }*/


    //}
}

