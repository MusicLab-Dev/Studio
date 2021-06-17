import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

StaticModulesViewTab {
    property real dragOldX: 0

    id: tabMouseArea
    x: tabIndex * modulesTabs.tabWidth
    z: drag.active ? 10 : 0
    drag.target: tabMouseArea
    drag.axis: Drag.XAxis
    drag.smoothed: true
    drag.minimumX: 0
    drag.maximumX: modulesTabs.totalDynamicTabWidth - modulesTabs.tabWidth
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    onPressed: dragOldX = x

    onXChanged: {
        if (drag.active) {
            var newIdx = Math.round(x / modulesTabs.tabWidth)
            if (newIdx < 0)
                newIdx = 0
            else if (newIdx >= tabRepeater.count)
                newIdx = tabRepeater.count - 1
            if (tabIndex != newIdx) {
                dragOldX = x
                modulesView.modules.move(tabIndex, newIdx, 1)
                modulesView.selectedModule = newIdx
                x = dragOldX
                dragOldX = newIdx * modulesTabs.tabWidth
            }
        }
    }

    onReleased: x = dragOldX

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