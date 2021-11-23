import QtQuick 2.15

import "../Default"

import AutomationModel 1.0

ControlsFlow {
    signal automationSelected(int automationIndex)

    id: controlsFlow
    baseMargin: 0

    controlsFlowBase.controlsRepeater.delegate: Column {
        property AutomationModel automation: controlsFlowBase.node ? controlsFlowBase.node.automations.getAutomation(index) : null

        id: delegateCol
        width: delegateLoader.width

        ControlsFlowLoader {
            id: delegateLoader
            color: controlsFlowBase.node.color
        }

        DefaultImageButton {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 20
            scaleFactor: 1
            source: "qrc:/Assets/Automation.png"
            colorDefault: delegateCol.automation && delegateCol.automation.count ? controlsFlowBase.nodeColor : "white"
            colorHovered: controlsFlowBase.nodeHoveredColor
            colorOnPressed: controlsFlowBase.nodePressedColor

            onReleased: automationSelected(index)
        }
    }
}
