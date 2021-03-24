import QtQuick 2.15
import QtQuick.Controls 2.15

import ControlModel 1.0
import AudioAPI 1.0

import "../../Default"
import "../../Common"

Repeater {
    delegate: Item {
        property ControlModel control: controlInstance.instance

        id: controlDelegate
        width: nodeView.dataHeaderAndContentWidth
        height: contentView.rowHeight

        Rectangle {
            id: dataBackground
            x: nodeView.dataHeaderLeftPadding
            y: nodeView.dataHeaderTopPadding
            width: nodeView.dataHeaderDisplayWidth
            height: parent.height - nodeView.dataHeaderVerticalPadding
            radius: nodeView.dataHeaderRadius
            color: "transparent"
            border.color: nodeDelegate.node ? nodeDelegate.node.color : "white"
            border.width: nodeView.dataHeaderBorderWidth

            DefaultText {
                id: controlName
                x: nodeView.dataHeaderSpacing
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameWidth
                height: nodeView.dataHeaderNameHeight
                horizontalAlignment: Text.AlignLeft
                text: controlDelegate.control ? controlDelegate.control.name : ""
                color: "white"
                elide: Text.ElideRight
                font.pointSize: nodeView.dataHeaderNamePointSize
            }

            MuteButton {
                id: muteMenuButton
                x: nodeView.dataHeaderMuteButtonX
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameHeight
                height: nodeView.dataHeaderNameHeight
                muted: controlDelegate.control ? controlDelegate.control.muted : false

                onMutedChanged: {
                    if (controlDelegate.control)
                        controlDelegate.control.muted = muted
                }
            }

            SettingsButton {
                id: settingsMenuButton
                x: nodeView.dataHeaderSettingsButtonX
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameHeight
                height: nodeView.dataHeaderNameHeight

                onReleased: {
                    controlSettingsMenu.openMenu(settingsMenuButton, nodeDelegate.node, controlDelegate.control, index)
                }
            }
        }

        ContentPlacementArea {
            id: placementArea
            x: nodeView.dataHeaderWidth
            width: nodeView.dataContentWidth
            height: contentView.rowHeight
            instances: controlDelegate.control.instances

            Repeater {
                model: controlDelegate.control.instances

                delegate: Rectangle {
                    x: contentView.xOffset + contentView.pixelsPerBeatPrecision * from
                    width: contentView.pixelsPerBeatPrecision * (to - from)
                    height: contentView.rowHeight
                    color: nodeDelegate.node.color
                }
            }
        }
    }
}