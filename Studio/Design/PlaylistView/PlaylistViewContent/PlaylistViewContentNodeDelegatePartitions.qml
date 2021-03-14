import QtQuick 2.15
import QtQuick.Controls 2.15

Repeater {
    delegate: Item {
        width: nodeView.width - nodeView.headerPluginWidth
        height: nodeView.rowHeight

        Rectangle {
            width: nodeView.headerDataWidth
            height: nodeView.rowHeight
            color: "red"
            border.color: "grey"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "Partition"
                font.pointSize: 24
            }
        }

        Rectangle {
            x: nodeView.headerDataWidth
            width: nodeView.width - nodeView.headerWidth
            height: nodeView.rowHeight
            color: "pink"
            opacity: 0.5
        }
    }
}