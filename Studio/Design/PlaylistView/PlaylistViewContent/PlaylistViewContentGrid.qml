import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
    readonly property var node: [
        1
    ]
    property real headerFactor: 0.1
    property real rowHeight: 50
    property real keyWidth: width * headerFactor
    readonly property real totalGridHeight: node.length * rowHeight

    id: grid
    color: "#4A8693"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        contentHeight: totalGridHeight

        Repeater {
            model: grid.node

            delegate: Item {

                width: grid.width
                height: grid.rowHeight
                y: index * grid.rowHeight

                Rectangle {
                    color: "red"
                    height: parent.height
                    width: parent.width
                }
            }
        }
    }
}
