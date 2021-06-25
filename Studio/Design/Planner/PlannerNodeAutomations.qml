import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

import PluginModelProxy 1.0

Repeater {
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
        property int modelIndex: index

        onModelIndexChanged: {
            if (modelIndex === nodeAutomations.count - 1)
                nodeAutomations.linkBottom = Qt.binding(function() { return y + height / 2 })
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