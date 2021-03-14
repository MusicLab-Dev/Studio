import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"
import "../../Common"

Item {
    id: header

    Rectangle {
        id: pluginBackground
        x: 2
        y: 6
        width: parent.width - 12
        height: parent.height - 12
        radius: width / 16
        color: delegate.node ? delegate.node.color : "black"

        DefaultText {
            id: nodeName
            x: 2
            y: 2
            text: delegate.node ? delegate.node.name : ""
            font.pointSize: 16
        }

        SettingsButton {
            id: settingsMenuButton
            x: addMenuButton.x - width - 2
            y: 2
            width: nodeName.height
            height: width

            onReleased: playlistViewContentPluginSettingsMenu.openMenu(addMenuButton, delegate.node, delegate.index)
        }

        AddButton {
            id: addMenuButton
            x: parent.width - width - 2
            y: 2
            width: nodeName.height
            height: width

            onReleased: playlistViewContentPluginAddMenu.openMenu(addMenuButton, delegate.node)
        }
    }
}