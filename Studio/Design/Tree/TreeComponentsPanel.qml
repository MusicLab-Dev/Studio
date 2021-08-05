import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import PluginTableModel 1.0

import "../Default"

Item {
    enum Type {
        Mixer,
        Sources,
        Effects,
        Tools,
        Void
    }

    function open(filt) {
        filterTemp = filt
        if (launched)
            restartAnim.start()
        else {
            filter = filt
            openAnim.start()
        }
        launched = true
    }

    function close() {
        launched = false
        filter = TreeComponentsPanel.Type.Void
        closeAnim.start()
    }

    property int filterTemp: TreeComponentsPanel.Type.Void
    property int filter: TreeComponentsPanel.Type.Void
    property bool launched: false
    property real durationAnimation: 300

    id: treeComponentsPanel

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: panel; property: "x"; to: panel.xOpen; duration: durationAnimation; easing.type: Easing.OutBack }
    }

    ParallelAnimation {
        id: closeAnim
        PropertyAnimation { target: panel; property: "x"; to: panel.xClose; duration: durationAnimation; easing.type: Easing.OutBack; }
    }

    SequentialAnimation {
        id: restartAnim
        ParallelAnimation {
            PropertyAnimation { target: panel; property: "x"; to: panel.xClose; duration: durationAnimation; easing.type: Easing.OutCubic; }
        }
        ScriptAction { script: treeComponentsPanel.filter = treeComponentsPanel.filterTemp }
        ParallelAnimation {
            PropertyAnimation { target: panel; property: "x"; to: panel.xOpen; duration: durationAnimation; easing.type: Easing.InCubic }
        }
    }


    /*
    Rectangle {
        id: buttonPanel

        anchors.right: panel.left
        anchors.rightMargin: 32
        anchors.top: parent.top
        anchors.topMargin: parent.height / 2 - height / 2

        width: parent.width * 0.04
        height: width
        opacity: 0.7
        color: themeManager.foregroundColor
        radius: 1000

        Image {
            id: plus
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: parent.height * 0.6
            source: "qrc:/Assets/Plus.png"
        }

        ColorOverlay {
                anchors.fill: plus
                source: plus
                color: "white"
            }

        MouseArea {
            anchors.fill: parent

            onPressed: {
                open()
            }

        }

    }
    */

    Item {
        property real widthContentRatio: 0.6
        property real xClose: parent.width - panelCategory.width
        property real xOpen: parent.width - width

        id: panel
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.15
        height: parent.height * 0.9
        x: xClose

        Item {
            id: panelCategory
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - parent.width * panel.widthContentRatio
            height: parent.height


            Column {
                height: parent.height
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                //spacing: parent.height * 0.005

                TreeComponentCategory {
                    text.text: "Mixer"
                    filter: TreeComponentsPanel.Type.Mixer
                }

                TreeComponentCategory {
                    text.text: "Sources"
                    filter: TreeComponentsPanel.Type.Sources
                }

                TreeComponentCategory {
                    text.text: "Effects"
                    filter: TreeComponentsPanel.Type.Effects
                }
            }
        }

        Item {
            property real widthOffset: 50

            id: panelContent
            anchors.left: panelCategory.right
            anchors.top: parent.top
            width: parent.width * panel.widthContentRatio
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
}
