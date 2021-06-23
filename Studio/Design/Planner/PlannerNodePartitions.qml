import QtQuick 2.15

import "../Default"

Row {
    property alias headerHovered: nodePartitionsHeaderMouseArea.containsMouse
    property alias headerPressed: nodePartitionsHeaderMouseArea.containsPress

    id: nodePartitions

    Item {
        id: nodePartitionsHeader
        width: contentView.rowHeaderWidth
        height: contentView.rowHeight * (nodeDelegate.isSelected ? 1.25 : 1)

        Item {
            id: nodePartitionsBackground
            x: nodeDelegate.isChild ? contentView.rowHeaderWidth * 0.25 : 10
            y: 5
            width: contentView.rowHeaderWidth - x - 10
            height: nodePartitions.height

            MouseArea {
                id: nodePartitionsHeaderMouseArea
                anchors.fill: parent
                hoverEnabled: true

                onReleased: {
                    nodeDelegate.isSelected = !nodeDelegate.isSelected
                }
            }

            DefaultText {
                anchors.centerIn: parent
                text: nodeDelegate.node ? nodeDelegate.node.name : "ERROR"
            }
        }
    }

    Item {
        id: nodePartitionsData
        width: contentView.rowDataWidth
        height: nodePartitionsHeader.height
    }
}