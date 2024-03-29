import QtQuick 2.15
import QtQuick.Controls 2.15

import PartitionsModel 1.0

import "../Default/"

DefaultComboBox {
    property PartitionsModel partitions

    id: control
    model: sequencerView.node ? sequencerView.node.partitions : null
    displayText: partitions && currentIndex !== -1 ? partitions.getPartition(currentIndex).name : ""

    delegate: ItemDelegate {
        property var targetPartition: partitionInstance.instance

        id: comboDelegate
        width: control.width
        hoverEnabled: true
        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: comboDelegate.targetPartition.name
            color: "white"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: parent.hovered ? themeManager.accentColor : themeManager.contentColor
            radius: 2
        }
    }
}
