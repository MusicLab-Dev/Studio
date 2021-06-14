import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

Item {
    readonly property real tabWidth: 200//Math.min(Math.max(tabArea.width / 8, 100), 200)
    readonly property real tabHeight: 35
    readonly property real totalTabWidth: tabRow.width
    readonly property bool allTabsInOneScreen: totalTabWidth <= width - tabHeight * 2
    property int selectedModule: 0
    readonly property int staticTabCount: 1

    id: modulesTabs
    width: parent.width
    height: tabHeight

    Rectangle {
        id: globalMenu
        width: modulesTabs.tabHeight
        height: modulesTabs.tabHeight
        color: "red"
    }

    Button {
        id: leftMoveButton
        x: globalMenu.width
        width: modulesTabs.tabHeight * !modulesTabs.allTabsInOneScreen
        height: modulesTabs.tabHeight
        text: "<"
        visible: !modulesTabs.allTabsInOneScreen
        enabled: tabArea.scrollOffset < 0

        onPressed: tabArea.scrollOffset = tabArea.ensureScrollOffset(tabArea.scrollOffset + modulesTabs.tabWidth)
        onDoubleClicked: tabArea.scrollOffset = 0
    }

    Item {
        function ensureScrollOffset(offset) {
            if (offset > 0)
                offset = 0
            else if (offset < minScrollOffset)
                offset = minScrollOffset
            return offset
        }

        readonly property real minScrollOffset: width - modulesTabs.totalTabWidth
        property real scrollOffset: 0

        id: tabArea
        anchors.left: leftMoveButton.right
        anchors.right: rightMoveButton.left
        height: parent.height
        clip: true

        onScrollOffsetChanged: {
            if (scrollOffset === behavior.targetValue) {
                if (leftMoveButton.pressed)
                    scrollOffset = tabArea.ensureScrollOffset(scrollOffset + modulesTabs.tabWidth)
                else if (rightMoveButton.pressed)
                    scrollOffset = tabArea.ensureScrollOffset(scrollOffset - modulesTabs.tabWidth)
            }
        }

        Behavior on scrollOffset {
            id: behavior
            NumberAnimation { duration: 500 }
        }

        Row {
            readonly property real minimumDragX: modulesTabs.staticTabCount * modulesTabs.tabWidth
            readonly property real maximumDragX: modulesTabs.totalTabWidth - modulesTabs.tabWidth

            id: tabRow
            x: tabArea.scrollOffset
            height: modulesTabs.height

            StaticModulesViewTab {
                id: playlistTab
                tabIndex: -1
            }

            Repeater {
                id: tabRepeater
                model: modulesView.modules

                delegate: ModulesViewTab {
                    tabIndex: index
                }
            }
        }
    }

    Button {
        id: rightMoveButton
        x: addTabButton.x - width
        width: modulesTabs.tabHeight * !modulesTabs.allTabsInOneScreen
        height: modulesTabs.tabHeight
        text: ">"
        visible: !modulesTabs.allTabsInOneScreen
        enabled: tabArea.scrollOffset > tabArea.minScrollOffset

        onPressed: {
            tabArea.scrollOffset = tabArea.ensureScrollOffset(tabArea.scrollOffset - modulesTabs.tabWidth)
        }

        onDoubleClicked: {
            tabArea.scrollOffset = tabArea.minScrollOffset
        }
    }

    ModulesViewNewTabButton {
        id: addTabButton
        x: Math.min(tabArea.x + modulesTabs.totalTabWidth, modulesTabs.width - width)
        width: modulesTabs.tabHeight
        height: modulesTabs.tabHeight
    }
}