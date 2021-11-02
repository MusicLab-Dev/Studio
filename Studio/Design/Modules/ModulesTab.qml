import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

ModulesStaticTab {
    function moveHandler() {
        var col = Math.max(Math.min(Math.round(x / modulesTabs.tabWidth), modulesTabs.tabsPerRow), 0)
        var row = Math.max(Math.min(Math.round(y / modulesTabs.tabHeight), modulesTabs.tabRows), 0)
        var newVisualIdx = Math.min(col + row * modulesTabs.tabsPerRow, modulesTabs.totalTabCount)
        var newIdx = Math.min(Math.max(newVisualIdx - modulesTabs.staticTabCount, 0), modulesView.modules.count - 1)
        if (tabIndex != newIdx)
            moveModule(tabIndex, newIdx)
    }

    property int visualTabIndex
    readonly property int columnIndex: visualTabIndex % modulesTabs.tabsPerRow
    readonly property int rowIndex: visualTabIndex / modulesTabs.tabsPerRow

    id: tab
    z: drag.active ? 10 : 0
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    drag.target: tab
    // drag.axis: Drag.XAxis
    drag.smoothed: true
    drag.minimumX: 0
    drag.maximumX: parent.width - modulesTabs.tabWidth
    drag.minimumY: 0
    drag.maximumY: parent.height - modulesTabs.tabHeight
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    onClicked: {
        if (mouse.button === Qt.MiddleButton)
            modulesView.removeModule(tab.tabIndex)
    }

    Binding on x {
        when: !drag.active
        value: columnIndex * modulesTabs.tabWidth
        restoreMode: Binding.RestoreNone
    }

    Binding on y {
        when: !drag.active
        value: rowIndex * modulesTabs.tabHeight
        restoreMode: Binding.RestoreNone
    }

    Connections {
        target: tab
        enabled: tab.drag.active

        function onXChanged() {
            moveHandler()
        }

        function onYChanged() {
            moveHandler()
        }
    }

    CloseButton {
        id: closeBtn
        width: parent.height / 3
        height: width
        anchors.right: parent.right
        anchors.rightMargin: width / 2
        anchors.verticalCenter: parent.verticalCenter

        onClicked: modulesView.removeModule(tab.tabIndex)
    }
}
