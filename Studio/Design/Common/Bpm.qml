import QtQuick 2.0

Rectangle {
    color: "#4A8693"

    TextEdit {
        id: name
        anchors.centerIn: parent
        text: qsTr("140:000")
        font.pixelSize: parent.height
    }
}
