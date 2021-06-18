import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Common"

import PluginModel 1.0

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
        clip: true

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

            onReleased: pluginSettingsMenu.openMenu(pluginSettingsMenuButton, nodeDelegate.node, nodeDelegate.nodeIndex)
        }

        Flow {
            id: pluginControlGrid
            y: nodeView.pluginHeaderNameHeight
            width: nodeView.pluginHeaderDisplayWidth
            padding: 2
            spacing: 2

            Repeater {
                id: pluginControlGridRepeater
                model: nodeDelegate.node ? nodeDelegate.node.plugin : null

                delegate: Loader {
                    focus: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    source: {
                        switch (controlType) {
                        case PluginModel.Boolean:
                            return "qrc:/Common/PluginControls/BooleanControl.qml"
                        case PluginModel.Integer:
                            return "qrc:/Common/PluginControls/IntegerControl.qml"
                        case PluginModel.Floating:
                            return "qrc:/Common/PluginControls/FloatingControl.qml"
                        case PluginModel.Enum:
                            return "qrc:/Common/PluginControls/EnumControl.qml"
                        default:
                            return ""
                        }
                    }
                }
            }
        }
    }
}