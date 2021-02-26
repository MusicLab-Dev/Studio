import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: boardViewBackground
    color: "#001E36"
    radius: 30

    BoardViewTitle {
        id: boardViewTitle
        width: parent.width
    }

    Rectangle {
        id: boardContentView
        color: "#4A8693"
        anchors.top: boardViewTitle.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.width * 0.02
        radius: 13

        GridView {
            id: gridView

            model: ListModel {
                ListElement {
                    boardWidth: 12
                    boardHeight: 8
                }
            }

            /*ListModel {
                ListElement {
                    type: 0
                    state: 0
                    pos: Qt.point(1, 1)
                }
                ListElement {
                    type: 0
                    state: 1
                    pos: Qt.point(2, 3)
                }
            }*/

            delegate: Rectangle {
                width: gridView.width / 4
                height: gridView.height / 4
                color: "red"
            }
        }
    }
}
