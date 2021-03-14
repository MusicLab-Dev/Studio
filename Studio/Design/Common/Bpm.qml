import QtQuick 2.15

Rectangle {
    color: "#4A8693"
    border.color: "white"
    border.width: 2
    radius: 5

    TextEdit {
        id: name
        anchors.centerIn: parent
        text: qsTr("140:000")
        font.pixelSize: parent.height * 0.75
        color: "white"
    }
/*
    Rectangle {
        height: parent.height* 0.25
        width: parent.width * 0.25
        anchors.centerIn: parent.BottomLeft
    }*/
}
