import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import "../Default"
import "../Common"

Item {
    readonly property int totalTabCount: staticTabCount + modulesView.modules.count
    readonly property int tabRows: 1 + (totalTabCount / tabsPerRow)
    readonly property int tabsPerRow: Math.round(tabArea.width / 200)
    readonly property real tabWidth: tabArea.width / tabsPerRow
    readonly property real tabHeight: 35
    readonly property bool allTabsInOneRow: tabRows === 1
    property int selectedModule: -staticTabCount
    readonly property int staticTabCount: 1
    property bool expanded: false

    id: modulesTabs
    width: parent.width
    height: expanded ? tabArea.height : tabHeight
    clip: true

    onAllTabsInOneRowChanged: {
        if (allTabsInOneRow)
            expanded = false
    }

    onExpandedChanged: {
        if (!expanded && selectedModule > tabsPerRow) {
            modulesView.moveModule(selectedModule, 0)
        }
    }

    Rectangle {
        id: backgroundTabs
        anchors.fill: parent
        color: Qt.darker(themeManager.contentColor, 1.1)
    }

    ModulesGlobalMenu {
        id: globalMenu
        width: modulesTabs.tabHeight
        height: modulesTabs.tabHeight
    }

    Item {
        id: tabArea
        anchors.left: globalMenu.right
        anchors.right: expandButton.left
        height: modulesTabs.tabHeight * modulesTabs.tabRows

        Row {
            id: staticTabRow

            ModulesStaticTab {
                id: treeTab
                tabIndex: -1
                source: "qrc:/Assets/Orchestra.png"
            }
        }

        Repeater {
            id: tabRepeater
            model: modulesView.modules

            delegate: ModulesTab {
                tabIndex: index
                visualTabIndex: tabIndex + modulesTabs.staticTabCount
                source: type === ModulesView.Planner ? "qrc:/Assets/Chrono.png" : "qrc:/Assets/Note.png"
            }
        }

        ModulesNewTabButton {
            id: addTabButton
            x: Math.floor(modulesTabs.totalTabCount % modulesTabs.tabsPerRow) * modulesTabs.tabWidth
            y: Math.floor(modulesTabs.totalTabCount / modulesTabs.tabsPerRow) * modulesTabs.tabHeight
            width: modulesTabs.tabHeight
            height: modulesTabs.tabHeight
        }
    }

    ModulesExpandButton {
        id: expandButton
        anchors.right: parent.right
        width: modulesTabs.tabHeight
        height: modulesTabs.tabHeight
        visible: !modulesTabs.allTabsInOneRow
    }
}
