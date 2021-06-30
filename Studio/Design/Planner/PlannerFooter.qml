import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }
}
