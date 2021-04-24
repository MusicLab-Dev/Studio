import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"
import "../../Common"

Item {
    id: header

    Rectangle {
        id: pluginBackground
        x: nodeView.pluginHeaderLeftPadding
        y: nodeView.pluginHeaderTopPadding
        width: nodeView.pluginHeaderDisplayWidth
        height: parent.height - nodeView.pluginHeaderVerticalPadding
        radius: nodeView.pluginHeaderRadius
        color: nodeDelegate.node ? nodeDelegate.node.color : "black"

        DefaultText {
            id: nodeName
            x: nodeView.pluginHeaderSpacing
            y: nodeView.pluginHeaderSpacing
            width: nodeView.pluginHeaderNameWidth
            height: nodeView.pluginHeaderNameHeight
            horizontalAlignment: Text.AlignLeft
            text: nodeDelegate.node ? nodeDelegate.node.name : ""
            color: "white"
            elide: Text.ElideRight
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: nodeView.pluginHeaderNamePixelSize
        }

        MuteButton {
            x: nodeView.pluginHeaderMuteButtonX
            y: nodeView.pluginHeaderSpacing
            width: nodeView.pluginHeaderNameHeight
            height: nodeView.pluginHeaderNameHeight
            muted: nodeDelegate.node ? nodeDelegate.node.muted : false

            onMutedChanged: {
                if (nodeDelegate.node)
                    nodeDelegate.node.muted = muted
            }
        }

        SettingsButton {
            id: pluginSettingsMenuButton
            x: nodeView.pluginHeaderSettingsButtonX
            y: nodeView.pluginHeaderSpacing
            width: nodeView.pluginHeaderNameHeight
            height: nodeView.pluginHeaderNameHeight

            onReleased: pluginSettingsMenu.openMenu(pluginSettingsMenuButton, nodeDelegate.node, index)
        }
    }
}