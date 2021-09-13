import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0
import PluginModel 1.0

import "../Default"

TreePanel {
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
                text.text: qsTr("Instruments")
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
            color: Qt.darker(themeManager.foregroundColor, 1.1)
        }

        MouseArea {
            anchors.fill: parent
            onPressedChanged: forceActiveFocus()
            onWheel: {} // Steal wheel events
        }

        ListView {
            id: treeComponentsListView
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.95
            clip: true
            spacing: 20
            model: PluginTableModelProxy {
                id: pluginTableProxy
                sourceModel: pluginTable
                tagsFilter: treeComponentsPanel.filter ? treeComponentsPanel.filter : -1
                //nameFilter: pluginsForeground.currentSearchText
            }

            delegate: TreeComponentDelegate {
                width: treeComponentsListView.width
                height: width
            }
        }
    }

}
