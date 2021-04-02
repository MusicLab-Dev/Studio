import QtQuick 2.15

Rectangle {
    property int moduleIndex: -1

    id: boardView
    color: themeManager.foregroundColor

    Text {
        anchors.centerIn: parent
        text: "Board view"
        color: "white"
    }
}
