import QtQuick 2.15
import QtQuick.Layouts 1.3

import "../Default"
import "../Common"

import PartitionsModel 1.0
import PartitionInstancesModel 1.0
import AutomationPreview 1.0
import AudioAPI 1.0

Row {
    function selectAutomation(index) {
        selectedAutomation = index
        showAutomations = true
    }

    function hideAutomations() {
        selectedAutomation = -1
        showAutomations = false
    }

    readonly property PartitionsModel partitions: nodeDelegate.node ? nodeDelegate.node.partitions : null
    readonly property PartitionInstancesModel instances: partitions ? partitions.instances : null
    property bool showAutomations: false
    property int selectedAutomation: -1

    id: nodeInstances

    Item {
        id: nodeInstancesHeader
        width: contentView.rowHeaderWidth
        height: contentView.rowHeight

        Item {
            id: nodeInstancesBackground
            x: nodeHeaderBackground.x
            y: nodeHeaderBackground.y
            width: nodeHeaderBackground.width
            height: nodeInstancesHeader.height

            RowLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                anchors.topMargin: 10
                height: parent.height * 0.3

                DefaultText {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 16
                    color: nodeDelegate.isSelected ? themeManager.foregroundColor : nodeDelegate.color
                    text: nodeDelegate.node ? nodeDelegate.node.name : qsTr("ERROR")
                    elide: Text.ElideRight
                }

                PluginFactoryImage {
                    id: menuButton
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    name: node ? node.plugin.title : ""
                    color: nodeDelegate.isSelected ? themeManager.foregroundColor : nodeDelegate.color
                    playing: contentView.playerBase.isPlayerRunning && soundMeter.peakPosition !== 0
                }

            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            RowLayout {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 10
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                height: parent.height * 0.3
                spacing: 10

                DefaultImageButton {
                    id: showAutomationsButton

                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    source: "qrc:/Assets/Automation.png"
                    scaleFactor: 1
                    showBorder: false
                    colorOnPressed: nodeDelegate.pressedColor
                    colorHovered: nodeDelegate.hoveredColor
                    colorDefault: nodeInstances.showAutomations ? "white" : nodeDelegate.accentColor

                    onReleased: {
                        if (nodeInstances.selectedAutomation === -1)
                            nodeInstances.selectedAutomation = 0
                        nodeInstances.showAutomations = !nodeInstances.showAutomations
                    }
                }

                DefaultComboBox {
                    id: automationCombobox
                    width: parent.width - showAutomationsButton.width - 5
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    visible: nodeInstances.showAutomations
                    model: nodeInstances.showAutomations ? nodeDelegate.node.plugin : null
                    currentIndex: nodeInstances.selectedAutomation
                    textRole: "controlTitle"
                    accentColor: nodeDelegate.accentColor

                    onActivated: nodeInstances.selectAutomation(index)
                }
            }
        }
    }

    Item {
        width: contentView.rowDataWidth
        height: contentView.rowHeight
        clip: true

        PlannerNodeInstancesRow {
            id: instancesView
            width: contentView.rowDataWidth
            height: contentView.rowHeight
        }

        PlannerNodeInstancesPlacementArea {
            id: placementView
            width: contentView.rowDataWidth
            height: contentView.rowHeight
            enabled: !nodeInstances.showAutomations
        }

        Rectangle {
            visible: nodeInstances.showAutomations
            color: themeManager.foregroundColor
            anchors.fill: parent
            opacity: 0.85
        }

        Repeater {
            model: nodeInstances.showAutomations && nodeDelegate.node ? nodeDelegate.node.plugin : null

            delegate: AutomationPreview {
                width: contentView.rowDataWidth
                height: contentView.rowHeight
                target: nodeDelegate.node.automations.getAutomation(index)
                range: contentView.displayRange
                pixelsPerBeatPrecision: contentView.pixelsPerBeatPrecision
                color: nodeDelegate.color
                isAccent: nodeInstances.selectedAutomation === index
            }
        }

        PlannerNodeAutomationPlacement {
            width: contentView.rowDataWidth
            height: contentView.rowHeight
            automation: nodeDelegate.node && nodeInstances.selectedAutomation !== -1 ? nodeDelegate.node.automations.getAutomation(nodeInstances.selectedAutomation) : null
            controlDescriptor: {
                if (!nodeDelegate.node || nodeInstances.selectedAutomation === -1)
                    return undefined
                else
                    return AudioAPI.getControlDescriptor(nodeDelegate.node.plugin, nodeInstances.selectedAutomation)
            }
        }
    }
}
