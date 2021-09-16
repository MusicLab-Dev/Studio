import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

import CursorManager 1.0

Item {
    property bool pluginsSquareComponentHovered: false
    property color color: "white"

    Component.onCompleted: color = pluginsView.tagsToColor(factoryTags)

    id: pluginDelegate
    width: pluginsGrid.cellWidth
    height: pluginsGrid.cellHeight

    Rectangle {
        id: pluginSquareComponent
        color: "transparent"
        border.color: pluginsSquareComponentArea.containsMouse ? pluginDelegate.color : "white"
        border.width: 1
        radius: width / 4
        width: pluginsGrid.cellWidth - x * 2
        height: width
        x: 7
        y: 10

        PluginFactoryImage {
            id: pluginIcon
            width: parent.width / 1.5
            height: width
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            name: factoryName
            playing: pluginsSquareComponentArea.containsMouse
            color: pluginDelegate.color
        }
    }

    DefaultText {
        id: title
        text: factoryName
        anchors.top: pluginSquareComponent.bottom
        width: parent.width
        y: parent.height + height * 0.5
        color: pluginsSquareComponentArea.containsMouse ? pluginDelegate.color : "#FFFFFF"
        opacity: pluginsSquareComponentArea.containsMouse ? 1 : 0.7
        font.pointSize: 14
        font.weight: Font.DemiBold
        elide: Qt.ElideRight
    }

    Text {
        id: description
        text: factoryDescription
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        color: pluginsSquareComponentArea.containsMouse ? pluginDelegate.color : "#FFFFFF"
        opacity: pluginsSquareComponentArea.containsMouse ? 1 : 0.7
        font.pointSize: 9
        font.weight: Font.Thin

        DefaultToolTip {
            id: toolTip
            text: factoryDescription
            visible: pluginsSquareComponentArea.containsMouse && description.truncated
        }
    }

    MouseArea {
        id: pluginsSquareComponentArea
        anchors.fill: parent
        hoverEnabled: true

        onHoveredChanged: {
            if (containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }

        onReleased: {
            pluginsView.acceptAndClose(factoryPath)
        }
    }
}
