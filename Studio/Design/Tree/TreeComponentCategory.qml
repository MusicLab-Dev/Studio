import QtQuick 2.0
import QtQuick.Layouts 1.3

import "../Default"

import ThemeManager 1.0
import PluginModel 1.0
import CursorManager 1.0

Item {
    property alias mouseArea: mouse
    property alias text: text
    property int filter: 0

    property color baseColor: themeManager.getColorFromSubChain(
        (filter & PluginModel.Tags.Instrument ? ThemeManager.SubChain.Blue :
        filter & PluginModel.Tags.Effect ? ThemeManager.SubChain.Red :
        ThemeManager.SubChain.Green),
        0
    )

    id: categoryComponent
    width: treeComponentsPanel.categorySize
    height: treeComponentsPanel.categorySize * 0.7

    Rectangle {
        anchors.fill: parent
        color: treeComponentsPanel.filter === filter ? baseColor : mouseArea.containsMouse ? themeManager.foregroundColor : themeManager.panelColor
        radius: 2
    }

    Item {
        width: parent.width * 0.7
        height: parent.height
        anchors.centerIn: parent

        DefaultText {
            id: text
            anchors.fill: parent
            font.pixelSize: 13
            font.bold: true
            text: ""
            color: treeComponentsPanel.filter === filter ? "white" : baseColor
            //color: mouseArea.containsMouse ? "white" : baseColor
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true

        onHoveredChanged: {
            if (containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }

        onPressed: {
            treeComponentsPanel.open(filter)
        }
    }
}
