import QtQuick 2.15
import QtQuick.Controls 2.15

import PartitionModel 1.0

import "../../Default"

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
                text: partitionDelegate.partition.name
                font.pointSize: 16
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