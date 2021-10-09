import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0
import PluginModel 1.0
import ThemeManager 1.0

import "../Default"

TreePanel {
    function tagsToColor(tags) {
        if (tags & PluginModel.Tags.Instrument) {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Blue, blueColorIndex++)
        } else if (tags & PluginModel.Tags.Effect) {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Red, redColorIndex++)
        } else {
            return themeManager.getColorFromSubChain(ThemeManager.SubChain.Green, greenColorIndex++)
        }
    }

    property int redColorIndex: 0
    property int greenColorIndex: 0
    property int blueColorIndex: 0

    id: treeComponentsPanel

    Item {
        id: panelCategory
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: panelCategoryWidth
        height: parent.height

        Column {
            height: parent.height
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

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

    Item {
        property real widthOffset: 50

        id: panelContent
        anchors.left: panelCategory.right
        anchors.top: parent.top
        width: panelContentWidth
        height: parent.height

        Rectangle {
            id: panelContentBackground
            width: parent.width + panelContent.widthOffset
            height: parent.height
            color: themeManager.backgroundColor
            opacity: 0.3
        }

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
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.95
            clip: true
            spacing: 20
            model: treeComponentsPanel.filter ? pluginTableProxy : null

            delegate: TreeComponentDelegate {
                width: treeComponentsListView.width
                height: width
            }
        }
    }

}
