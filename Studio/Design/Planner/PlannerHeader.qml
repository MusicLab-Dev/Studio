
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Common"

Rectangle {
    color: themeManager.panelColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    ClipboardIndicator {
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.01
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.1
    }
}
