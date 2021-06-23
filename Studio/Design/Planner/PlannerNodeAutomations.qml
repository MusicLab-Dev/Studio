import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

import PluginModelProxy 1.0

Repeater {
    id: nodeAutomations

    model: PluginModelProxy {
        sourceModel: nodeDelegate.isSelected && nodeDelegate.node ? nodeDelegate.node.plugin : null
    }

    delegate: Column {
        Row {
            Item {
                id: nodeAutomationHeader
                width: contentView.rowHeaderWidth
                height: contentView.rowHeight

                Rectangle {
                    x: parent.width * 0.125
                    y: contentView.rowHeight / 2 - 2
                    width: parent.width * (0.35 - 0.125)
                    height: 4
                    color: nodeDelegate.color
                }

                Rectangle {
                    id: nodeAutomationHeaderBackground
                    x: contentView.rowHeaderWidth * 0.35
                    y: 5
                    width: contentView.rowHeaderWidth * 0.65 - 10
                    height: contentView.rowHeight - 10
                    color: nodeDelegate.node ? nodeDelegate.node.color : "black"
                    radius: 15

                    DefaultText {
                        anchors.centerIn: parent
                        text: controlTitle
                    }
                }
            }

            Item {
                id: nodeAutomationData
                width: contentView.rowDataWidth
                height: contentView.rowHeight
            }
        }

        PlannerRowDataLine {}
    }
}