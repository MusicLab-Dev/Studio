import QtQuick 2.15
import QtQuick.Controls 2.15

import PartitionModel 1.0

import "../../../Default"
import "../../../Common"

Repeater {
    delegate: Item {
        property PartitionModel partition: partitionInstance.instance

        id: partitionDelegate
        width: nodeView.width - nodeView.headerPluginWidth
        height: nodeView.rowHeight

        Rectangle {
            width: nodeView.headerDataWidth
            height: nodeView.rowHeight
            color: "transparent"
            border.color: "white"
            border.width: 2

            DefaultText {
                id: partitionName
                x: 2
                y: 2
                width: removeButton.x - 4
                height: implicitHeight
                text: partitionDelegate.partition ? partitionDelegate.partition.name : ""
                visible: nodeView.rowHeight > height
                color: "white"
                font.pointSize: 16
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
            }

            CloseButton {
                id: removeButton
                x: parent.width - width - 2
                y: 2
                width: partitionName.height
                height: width
                visible: partitionName.visible

                onReleased: nodeDelegate.node.partitions.remove(index)
            }
        }

        Item {
            x: nodeView.headerDataWidth
            width: nodeView.width - nodeView.headerWidth
            height: nodeView.rowHeight

            Repeater {
                // model:
            }
        }
    }
}