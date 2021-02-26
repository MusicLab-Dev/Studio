import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property real xOffset: 0
    property real yOffset: (1 - ((flickable.contentY % piano.rowHeight) / piano.rowHeight)) * piano.rowHeight
    property int displayedRowCount: height  / piano.rowHeight

    id: grid
    color: "#4A8693"

    Repeater {
        model: displayedRowCount

        delegate: Rectangle {
            y: yOffset + index * piano.rowHeight
            width: parent.width
            height: 1
            color: "red"
        }
    }
}
