import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0
import PluginModel 1.0
import ThemeManager 1.0

import "../Default"

Row {
    function open(requestedFilter) {
        filter = requestedFilter
        opened = true
    }

    function close() {
        filter = 0
        opened = false
    }

    function tagsToColor(tags) {
        if (tags & PluginModel.Tags.Instrument) {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Blue, blueColorIndex++)
        } else if (tags & PluginModel.Tags.Effect) {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Red, redColorIndex++)
        } else {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Green, greenColorIndex++)
        }
    }

    property bool opened: false
    property real cellSize: Math.max(Math.min(125, parent.height / 8), 84)
    property real categorySize: Math.max(Math.min(100, parent.height / 8), 70)

    // List view filter
    property int filter: 0

    // Color chain
    property int redColorIndex: 0
    property int greenColorIndex: 0
    property int blueColorIndex: 0

    id: treeComponentsPanel

    Rectangle {
        id: panelCategory
        anchors.verticalCenter: parent.verticalCenter
        width: categoryColumn.width + 12
        height: categoryColumn.height + 12
        color: themeManager.contentColor
        radius: 6

        Column {
            id: categoryColumn
            anchors.centerIn: parent
            spacing: 3

            TreeComponentCategory {
                text.text: qsTr("Groups")
                filter: PluginModel.Tags.Group
            }

            TreeComponentCategory {
                text.text: qsTr("Instrum.")
                filter: PluginModel.Tags.Instrument
            }

            TreeComponentCategory {
                text.text: qsTr("Effects")
                filter: PluginModel.Tags.Effect
            }
        }
    }

    Rectangle {
        id: panelContent
        width: treeComponentsPanel.cellSize + 24
        height: treeComponentsPanel.height
        color: themeManager.contentColor
        opacity: 1
        radius: 6
        visible: treeComponentsPanel.opened

        MouseArea {
            anchors.fill: parent
            onPressedChanged: forceActiveFocus()
            onWheel: {} // Steal wheel events
        }

        PluginTableModelProxy {
            id: pluginTableProxy
            sourceModel: pluginTable
            tagsFilter: treeComponentsPanel.filter
            //nameFilter: pluginsForeground.currentSearchText
        }

        ListView {
            id: treeComponentsListView
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            anchors.fill: parent
            clip: true
            spacing: 12
            model: treeComponentsPanel.filter ? pluginTableProxy : null
            flickDeceleration: 7000
            maximumFlickVelocity: 1500

            delegate: TreeComponentDelegate {
                width: treeComponentsListView.width - 24
                x: 12
            }
        }
    }
}
