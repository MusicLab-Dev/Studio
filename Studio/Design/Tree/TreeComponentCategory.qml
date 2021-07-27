import QtQuick 2.0
import QtQuick.Layouts 1.3

import "../Default"

Rectangle {
    property alias mouseArea: mouse
    property alias text: text

    property int filter: 0

    width: parent.width
    height: parent.height * 0.1
    color: mouseArea.containsMouse ? themeManager.accentColor : treeComponentsPanel.filter === filter ? Qt.darker(themeManager.foregroundColor, 1.1) : Qt.lighter(themeManager.foregroundColor, 1.2)

    DefaultText {
        id: text
        anchors.fill: parent
        font.pixelSize: 20
        fontSizeMode: Text.Fit
        text: ""
        color: mouseArea.containsMouse ? Qt.darker(themeManager.foregroundColor, 1.1) : treeComponentsPanel.filter === filter ? themeManager.accentColor : "white"
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true

        onPressed: {
            open(filter)
        }
    }

}
