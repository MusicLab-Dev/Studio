import QtQuick 2.0
import QtQuick.Layouts 1.3

import "../Default"

import ThemeManager 1.0
import PluginModel 1.0
import CursorManager 1.0

Rectangle {
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
    width: parent.width
    height: panelCategoryHeight
    color: treeComponentsPanel.filter === filter ? Qt.darker(themeManager.foregroundColor, 1.1) : mouseArea.containsMouse ? baseColor : Qt.lighter(themeManager.foregroundColor, 1.2)

    DefaultText {
        id: text
        anchors.fill: parent
        font.pixelSize: 20
        fontSizeMode: Text.Fit
        text: ""
        color: mouseArea.containsMouse ? "white" : baseColor
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
            open(filter)
        }
    }

}
