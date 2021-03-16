import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../../Default"
import "../../../Common"

Item {
    id: header

    Rectangle {
        id: pluginBackground
        x: 2
        y: 6
        width: parent.width - 12
        height: parent.height - 12
        radius: width / 16
        color: nodeDelegate.node ? nodeDelegate.node.color : "black"

        DefaultText {
            id: nodeName
            x: 2
            y: 2
            width: settingsMenuButton.x - 4
            height: implicitHeight
            text: nodeDelegate.node ? nodeDelegate.node.name : ""
            visible: nodeView.rowHeight > height
            color: "white"
            font.pointSize: 16
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignLeft
        }

        SettingsButton {
            id: settingsMenuButton
            x: addMenuButton.x - width - 2
            y: 2
            width: nodeName.height
            height: width
            visible: nodeName.visible

            onReleased: playlistViewContentNodeViewPluginSettingsMenu.openMenu(addMenuButton, nodeDelegate.node, index)
        }

        AddButton {
            id: addMenuButton
            x: parent.width - width - 2
            y: 2
            width: nodeName.height
            height: width
            visible: nodeName.visible

            onReleased: playlistViewContentNodeViewPluginAddMenu.openMenu(addMenuButton, nodeDelegate.node)
        }
    }
}