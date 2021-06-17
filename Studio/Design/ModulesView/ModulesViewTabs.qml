import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"

Item {
    readonly property real tabWidth: 200
    readonly property real tabHeight: 35
    readonly property real totalStaticTabWidth: staticTabCount * tabWidth
    readonly property real totalDynamicTabWidth: modules.count * tabWidth
    readonly property real totalTabWidth: tabRow.width
    readonly property bool allTabsInOneScreen: totalTabWidth <= width - tabHeight * 2
    property int selectedModule: -staticTabCount
    readonly property int staticTabCount: 1
    readonly property alias scrollOffsetIsMoving: scrollOffsetNumberAnimation.running

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

        onPressed: tabArea.scroll(modulesTabs.tabWidth)
        onDoubleClicked: tabArea.scrollLeftMost()
    }

    Item {
        function scroll(offset) {
            var newScrollOffset = scrollOffset + offset
            if (newScrollOffset > 0)
                newScrollOffset = 0
            else if (newScrollOffset < minScrollOffset)
                newScrollOffset = minScrollOffset
            scrollOffset = newScrollOffset
        }

        function scrollLeftMost() {
            tabArea.scrollOffset = 0
        }

        function scrollRightMost() {
            tabArea.scrollOffset = tabArea.minScrollOffset
        }

        readonly property real minScrollOffset: width - modulesTabs.totalTabWidth
        property real scrollOffset: 0

        id: tabArea
        anchors.left: leftMoveButton.right
        anchors.right: rightMoveButton.left
        height: parent.height
        clip: true

        Behavior on scrollOffset {
            NumberAnimation {
                id: scrollOffsetNumberAnimation
                duration: 500

                onRunningChanged: {
                    if (leftMoveButton.pressed)
                        tabArea.scroll(modulesTabs.tabWidth)
                    else if (rightMoveButton.pressed)
                        tabArea.scroll(-modulesTabs.tabWidth)
                }
            }
        }

        Row {
            id: tabRow
            x: tabArea.scrollOffset
            height: parent.height

            StaticModulesViewTab {
                id: playlistTab
                tabIndex: -1
            }

            Item {
                id: dynamicTabRow
                width: modulesTabs.totalDynamicTabWidth
                height: parent.height

                Repeater {
                    id: tabRepeater
                    model: modulesView.modules

                    delegate: ModulesViewTab {
                        tabIndex: index
                    }
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

        onPressed: tabArea.scroll(-modulesTabs.tabWidth)

        onDoubleClicked: tabArea.scrollRightMost()
    }

    ModulesViewNewTabButton {
        id: addTabButton
        x: Math.min(tabArea.x + modulesTabs.totalTabWidth, modulesTabs.width - width)
        width: modulesTabs.tabHeight
        height: modulesTabs.tabHeight
    }
}