import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Help"
import "../Common"

Rectangle {
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
        onClicked: helpHandler.open()
    }

    ClipboardIndicator {
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.01
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.1

        HelpArea {
            name: qsTr("Clipboard")
            description: qsTr("Description")
            position: HelpHandler.Position.Bottom
            externalDisplay: true
        }
    }

    PlannerEdition {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        height: parent.height * 0.75
        width: parent.width * 0.4
    }
}
