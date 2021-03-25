import QtQuick 2.15
import QtQuick.Controls 2.15

import ControlModel 1.0
import AutomationModel 1.0
import AudioAPI 1.0

import "../../Default"
import "../../Common"

Repeater {
    delegate: Item {
        property ControlModel control: controlInstance.instance

        id: controlDelegate
        width: nodeView.dataHeaderAndContentWidth
        height: Math.max(automationColumn.height, contentView.rowHeight)

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

            Rectangle {
                width: nodeView.dataHeaderControlRectangleWidth
                height: nodeView.dataHeaderControlRectangleHeight
                color: dataBackground.border.color
            }

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
                id: controlSettingsMenuButton
                x: nodeView.dataHeaderSettingsButtonX
                y: nodeView.dataHeaderSpacing
                width: nodeView.dataHeaderNameHeight
                height: nodeView.dataHeaderNameHeight

                onReleased: controlSettingsMenu.openMenu(controlSettingsMenuButton, nodeDelegate.node, controlDelegate.control, index)
            }
        }

        Column {
            id: automationColumn
            width: nodeView.dataHeaderAndContentWidth

            Repeater {
                model: controlDelegate.control

                delegate: Item {
                    property AutomationModel automation: automationInstance.instance

                    id: automationDelegate
                    width: nodeView.dataHeaderAndContentWidth
                    height: contentView.rowHeight

                    DefaultText {
                        id: automationName
                        visible: index !== 0 || nodeView.dataFirstAutomationVisible
                        x: nodeView.dataHeaderSpacing
                        y: index !== 0 ? nodeView.dataHeaderSpacing : nodeView.dataFirstAutomationNameY
                        width: nodeView.dataHeaderNameWidth
                        height: nodeView.dataHeaderNameHeight
                        horizontalAlignment: Text.AlignLeft
                        text: automationDelegate.automation ? automationDelegate.automation.name : ""
                        color: "white"
                        elide: Text.ElideRight
                        font.pointSize: nodeView.dataHeaderNamePointSize
                    }

                    MuteButton {
                        visible: index !== 0 || nodeView.dataFirstAutomationVisible
                        x: nodeView.dataHeaderMuteButtonX
                        y: automationName.y
                        width: nodeView.dataHeaderNameHeight
                        height: nodeView.dataHeaderNameHeight
                        muted: automationDelegate.automation ? automationDelegate.automation.muted : false

                        onMutedChanged: {
                            if (automationDelegate.automation)
                                automationDelegate.automation.muted = muted
                        }
                    }

                    SettingsButton {
                        id: automationSettingsMenuButton
                        visible: index !== 0 || nodeView.dataFirstAutomationVisible
                        x: nodeView.dataHeaderSettingsButtonX
                        y: automationName.y
                        width: nodeView.dataHeaderNameHeight
                        height: nodeView.dataHeaderNameHeight

                        onReleased: automationSettingsMenu.openMenu(automationSettingsMenuButton, controlDelegate.control, automationDelegate.automation, index)
                    }

                    ContentPlacementArea {
                        id: placementArea
                        x: nodeView.dataHeaderWidth
                        width: nodeView.dataContentWidth
                        height: contentView.rowHeight
                        instances: automationDelegate.automation ? automationDelegate.automation.instances : null

                        Repeater {
                            model: placementArea.instances

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
        }
    }
}