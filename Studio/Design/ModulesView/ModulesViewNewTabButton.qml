import QtQuick 2.15

import "../Default"

Rectangle {
    property real barSize: width / 4

    id: newTabButton
    color: themeManager.foregroundColor
    border.color: "black"

    MouseArea {
        anchors.fill: parent
        onClicked: modulesView.addNewSequencer()
    }

    Rectangle {
        width: barSize
        height: barSize / 8
        anchors.centerIn: parent
        radius: 20
    }

    Rectangle {
        width: barSize / 8
        height: barSize
        anchors.centerIn: parent
        radius: 20
    }
}
