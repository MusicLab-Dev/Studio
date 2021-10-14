import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

import PluginModelProxy 1.0
import AutomationsModel 1.0
import AutomationModel 1.0

Repeater {
    property AutomationsModel automations: nodeDelegate.node ? nodeDelegate.node.automations : null
    property real linkBottom: 0
    property alias pluginProxy: pluginProxy

    id: nodeAutomations

    model: PluginModelProxy {
        id: pluginProxy
        sourceModel: nodeDelegate.isSelected && nodeDelegate.node ? nodeDelegate.node.plugin : null
    }

    onCountChanged: {
        if (!count)
            linkBottom = Qt.binding(function() { return 0 })
    }

    delegate: Column {
        property AutomationModel automation: nodeAutomations.automations ? nodeAutomations.automations.getAutomation(controlParamID) : null

        id: automationDelegate

        Component.onCompleted: {
            if (index === nodeAutomations.count - 1)
                nodeAutomations.linkBottom = Qt.binding(function() { return y + height / 2 })
        }

        Connections {
            target: nodeAutomations

            function onCountChanged() {
                if (index === nodeAutomations.count - 1)
                    nodeAutomations.linkBottom = Qt.binding(function() { return y + height / 2 })
            }
        }

        Row {
            Item {
                id: nodeAutomationHeader
                width: contentView.rowHeaderWidth
                height: contentView.rowHeight

                Rectangle {
                    x: nodeDelegate.isChild ? contentView.linkChildOffset : contentView.linkOffset
                    y: contentView.rowHeight / 2 - contentView.linkHalfThickness
                    width: contentView.automationOffset - x
                    height: contentView.linkThickness
                    color: nodeDelegate.color
                }

                Rectangle {
                    id: nodeAutomationHeaderBackground
                    x: contentView.automationOffset
                    y: contentView.headerHalfMargin
                    width: contentView.rowHeaderWidth - x - contentView.headerMargin
                    height: contentView.rowHeight - contentView.headerMargin
                    color: nodeDelegate.node ? nodeDelegate.node.color : "black"
                    radius: 6

                    DefaultText {
                        x: 10
                        width: parent.width * 0.5
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignLeft
                        fontSizeMode: Text.HorizontalFit
                        font.pointSize: 20
                        color: nodeDelegate.accentColor
                        text: controlTitle
                        wrapMode: Text.Wrap
                    }

                    DefaultImageButton {
                        readonly property bool isMuted: false //nodeDelegate.node ? nodeDelegate.node.muted : false

                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: height
                        height: Math.min(parent.height / 2, 50)
                        source: isMuted ? "qrc:/Assets/Muted.png" : "qrc:/Assets/Unmuted.png"
                        showBorder: false
                        scaleFactor: 1
                        colorDefault: nodeDelegate.accentColor
                        colorHovered: nodeDelegate.hoveredColor
                        colorOnPressed: nodeDelegate.pressedColor

                        // onReleased: nodeDelegate.node.muted = !isMuted
                    }
                }
            }

            PlannerNodeAutomationRow {
                id: automationRow
                width: contentView.rowDataWidth
                height: contentView.rowHeight
            }
        }

        PlannerRowDataLine {}
    }
}
