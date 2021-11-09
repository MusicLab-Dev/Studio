import QtQuick 2.15

import "../Default"

ControlsFlow {
    signal automationSelected(int automationIndex)

    id: controlsFlow
    baseMargin: 0

    controlsFlowBase.controlsRepeater.delegate: Column {
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
            colorDefault: controlsFlowBase.nodeColor
            colorHovered: controlsFlowBase.nodeHoveredColor
            colorOnPressed: controlsFlowBase.nodePressedColor

            onReleased: automationSelected(index)
        }
    }
}
