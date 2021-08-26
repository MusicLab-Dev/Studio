import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0

import "../Default"

TreePanel {
    enum Type {
        Mixer,
        Sources,
        Effects,
        Tools,
        Void
    }


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
                text.text: qsTr("Mixer")
                filter: TreeComponentsPanel.Type.Mixer
            }

            TreeComponentCategory {
                text.text: qsTr("Sources")
                filter: TreeComponentsPanel.Type.Sources
            }

            TreeComponentCategory {
                text.text: qsTr("Effects")
                filter: TreeComponentsPanel.Type.Effects
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
                tagsFilter: {
                    if (treeComponentsPanel.filter === TreeComponentsPanel.Type.Void)
                        return -1
                    if (treeComponentsPanel.filter === TreeComponentsPanel.Type.Sources)
                        return PluginTableModel.Tags.Synth | PluginTableModel.Tags.Sampler | PluginTableModel.Tags.Piano
                    if (treeComponentsPanel.filter === TreeComponentsPanel.Type.Effects)
                        return PluginTableModel.Tags.Analyzer | PluginTableModel.Tags.Delay | PluginTableModel.Tags.Distortion |
                               PluginTableModel.Tags.EQ | PluginTableModel.Tags.Filter | PluginTableModel.Tags.Distortion
                    if (treeComponentsPanel.filter === TreeComponentsPanel.Type.Mixer)
                        return PluginTableModel.Tags.Mastering
                    return 0;

                }
                //nameFilter: pluginsForeground.currentSearchText
            }

            delegate: TreeComponentDelegate {
                width: treeComponentsListView.width
                height: width
            }
        }
    }

}
