import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

StaticModulesViewTab {
    id: tabMouseArea
    z: drag.active ? 10 : 0
    drag.target: tabMouseArea
    drag.axis: Drag.XAxis
    drag.smoothed: true
    drag.minimumX: 0
    drag.maximumX: modulesTabs.totalDynamicTabWidth - modulesTabs.tabWidth
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    Binding on x {
        when: !drag.active
        value: tabIndex * modulesTabs.tabWidth
        restoreMode: Binding.RestoreNone
    }

    Connections {
        target: tabMouseArea
        enabled: tabMouseArea.drag.active

        function onXChanged() {
            var newIdx = Math.round(x / modulesTabs.tabWidth)
            if (newIdx < 0)
                newIdx = 0
            else if (newIdx >= tabRepeater.count)
                newIdx = tabRepeater.count - 1
            if (tabIndex != newIdx) {
                modulesView.modules.move(tabIndex, newIdx, 1)
                modulesView.selectedModule = newIdx
                if (!modulesTabs.scrollOffsetIsMoving) {
                    var offset = x + tabArea.scrollOffset
                    if (offset < 0) {
                        console.log("Scrolling left", modulesTabs.tabWidth)
                        tabArea.scroll(modulesTabs.tabWidth)
                    } else if (offset > tabArea.width - modulesTabs.tabWidth) {
                        console.log("Scrolling right", -modulesTabs.tabWidth)
                        tabArea.scroll(-modulesTabs.tabWidth)
                    }
                }
            }
        }
    }

    CloseButton {
        id: closeBtn
        width: parent.height / 3
        height: width
        anchors.right: parent.right
        anchors.rightMargin: width / 2
        anchors.verticalCenter: parent.verticalCenter

        onClicked: modules.removeModule(tabMouseArea.tabIndex)
    }
}