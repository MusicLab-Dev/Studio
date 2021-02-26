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
            model: ListModel {
                ListElement {
                    size: Qt.size(12, 8)
                }
                ListElement {
                    size: Qt.size(10, 6)
                }
                ListElement {
                    size: Qt.size(10, 10)
                }
                ListElement {
                    size: Qt.size(12, 8)
                }
                ListElement {
                    size: Qt.size(10, 6)
                }
                ListElement {
                    size: Qt.size(10, 10)
                }
            }

            delegate: Rectangle {
            }
        }
    }
}
