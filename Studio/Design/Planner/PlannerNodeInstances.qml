import QtQuick 2.15

import "../Default"

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

            DefaultText {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 16
                color: nodeDelegate.isSelected ? themeManager.foregroundColor : nodeDelegate.color
                text: nodeDelegate.node ? nodeDelegate.node.name : qsTr("ERROR")
                elide: Text.ElideRight
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                x: 5
                width: nodeHeaderBackground.width - 10
                height: nodeHeaderBackground.height / 3
                spacing: 5

                DefaultImageButton {
                    id: showAutomationsButton
                    width: parent.height
                    height: parent.height
                    source: "qrc:/Assets/Automation.png"
                    scaleFactor: 1
                    showBorder: false
                    colorOnPressed: nodeDelegate.pressedColor
                    colorHovered: nodeDelegate.hoveredColor
                    colorDefault: nodeInstances.showAutomations ? "white" : nodeDelegate.accentColor

                    onReleased: nodeInstances.showAutomations = !nodeInstances.showAutomations
                }

                DefaultComboBox {
                    id: automationCombobox
                    width: parent.width - showAutomationsButton.width - 5
                    height: parent.height * 0.8
                    anchors.verticalCenter: parent.verticalCenter
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
                target: nodeDelegate.node.automations.getAutomation(index)
                range: contentView.displayRange
                pixelsPerBeatPrecision: contentView.pixelsPerBeatPrecision
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
