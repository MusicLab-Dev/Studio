import QtQuick 2.15
import QtQuick.Controls 2.15

import ControlModel 1.0
import AutomationModel 1.0
import AudioAPI 1.0
import InstancesModelProxy 1.0

import "../Default"
import "../Common"

Repeater {
    delegate: Item {
        readonly property int controlIndex: index
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
                fontSizeMode: Text.HorizontalFit
                font.pixelSize: nodeView.dataHeaderNamePixelSize
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

                onReleased: controlSettingsMenu.openMenu(controlSettingsMenuButton, nodeDelegate.node, controlDelegate.control, controlDelegate.controlIndex)
            }
        }

        Column {
            id: automationColumn
            width: nodeView.dataHeaderAndContentWidth

            Repeater {
                model: controlDelegate.control

                delegate: Item {
                    readonly property int automationIndex: index
                    property AutomationModel automation: automationInstance.instance

                    id: automationDelegate
                    width: nodeView.dataHeaderAndContentWidth
                    height: contentView.rowHeight

                    DefaultText {
                        id: automationName
                        visible: automationDelegate.automationindex !== 0 || nodeView.dataFirstAutomationVisible
                        x: nodeView.dataHeaderSpacing
                        y: automationDelegate.automationindex !== 0 ? nodeView.dataHeaderSpacing : nodeView.dataFirstAutomationNameY
                        width: nodeView.dataHeaderNameWidth
                        height: nodeView.dataHeaderNameHeight
                        horizontalAlignment: Text.AlignLeft
                        text: automationDelegate.automation ? automationDelegate.automation.name : ""
                        color: "white"
                        elide: Text.ElideRight
                        font.pointSize: nodeView.dataHeaderNamePointSize
                    }

                    MuteButton {
                        visible: automationDelegate.automationindex !== 0 || nodeView.dataFirstAutomationVisible
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
                        visible: automationDelegate.automationindex !== 0 || nodeView.dataFirstAutomationVisible
                        x: nodeView.dataHeaderSettingsButtonX
                        y: automationName.y
                        width: nodeView.dataHeaderNameHeight
                        height: nodeView.dataHeaderNameHeight

                        onReleased: automationSettingsMenu.openMenu(automationSettingsMenuButton, controlDelegate.control, automationDelegate.automation, automationDelegate.automationIndex)
                    }

                    Item {
                        x: nodeView.dataHeaderWidth
                        width: nodeView.dataContentWidth
                        height: contentView.rowHeight
                        clip: true

                        Repeater {
                            model: InstancesModelProxy {
                                range: AudioAPI.beatRange(-contentView.xOffset / contentView.pixelsPerBeatPrecision, (placementArea.width - contentView.xOffset) / contentView.pixelsPerBeatPrecision)
                                sourceModel: placementArea.instances
                            }

                            delegate: Rectangle {
                                x: contentView.xOffset + contentView.pixelsPerBeatPrecision * from
                                width: contentView.pixelsPerBeatPrecision * (to - from)
                                height: contentView.rowHeight
                                color: nodeDelegate.node.color
                            }
                        }
                    }

                    PlaylistInstancesPlacementArea {
                        id: placementArea
                        x: nodeView.dataHeaderWidth
                        width: nodeView.dataContentWidth
                        height: contentView.rowHeight
                        instances: automationDelegate.automation ? automationDelegate.automation.instances : null
                        brushStep: contentView.placementBeatPrecisionBrushStep
                    }
                }
            }
        }
    }
}