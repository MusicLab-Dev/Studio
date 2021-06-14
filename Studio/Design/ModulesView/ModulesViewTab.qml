import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

StaticModulesViewTab {
    property real dragOldX: 0

    id: tabMouseArea
    z: drag.active ? 10 : 0
    drag.target: tabMouseArea
    drag.axis: Drag.XAxis
    drag.smoothed: true
    drag.minimumX: tabRow.minimumDragX
    drag.maximumX: tabRow.maximumDragX
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    onPressed: dragOldX = x

    onReleased: {
        var newIdx = Math.round(x / modulesTabs.tabWidth)
        if (newIdx < 0)
            newIdx = 0
        else if (newIdx >= tabRepeater.count)
            newIdx = tabRepeater.count - 1
        if (tabIndex != newIdx) {
            modulesView.modules.move(tabIndex, newIdx, 1)
            modulesView.selectedModule = newIdx
        } else
            x = dragOldX
    }

    CloseButton {
        id: closeBtn
        width: parent.height / 3
        height: width
        anchors.right: parent.right
        anchors.rightMargin: width / 2
        anchors.verticalCenter: parent.verticalCenter

        onClicked: modules.removeModule(tabIndex)
    }
}