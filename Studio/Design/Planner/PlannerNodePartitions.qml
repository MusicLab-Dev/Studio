import QtQuick 2.15

import "../Default"

Row {
    property alias headerHovered: nodePartitionsHeaderMouseArea.containsMouse
    property alias headerPressed: nodePartitionsHeaderMouseArea.containsPress

    id: nodePartitions

    Item {
        id: nodePartitionsHeader
        width: contentView.rowHeaderWidth
        height: nodeDelegate.isSelected ? contentView.selectedRowHeight : contentView.rowHeight

        Item {
            id: nodePartitionsBackground
            x: nodeDelegate.isChild ? contentView.childOffset : contentView.headerMargin
            y: contentView.headerHalfMargin
            width: contentView.rowHeaderWidth - x - contentView.headerMargin
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