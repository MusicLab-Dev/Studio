import QtQuick 2.15

import "../Default"

ControlsFlow {
    property int automationIndex: -1

    id: controlsFlow
    baseMargin: 0

    headerText.text: {
        if (automationIndex === -1 || !node)
            return headerText.defaultText
        else
            return node.name + " automation\n" + node.plugin.getControlName(automationIndex)
    }

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
            image.fillMode: Image.PreserveAspectCrop

            onReleased: controlsFlow.automationIndex = index
        }
    }

    Rectangle {
        anchors.leftMargin: controlsFlow.headerRow.width
        anchors.fill: parent
        color: "red"
        opacity: 0.5
        visible: automationIndex !== -1
    }
}
