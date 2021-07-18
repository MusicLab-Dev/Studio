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

        property real widthContentRatio: 0.5
        property real rad: 32
        property real xClose: parent.width - panelCategory.width + rad
        property real xOpen: parent.width - width + rad

        id: panel
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.15
        height: parent.height * 0.9
        x: xClose

        Item {
            id: panelCategory
            anchors.left: parent.left
            anchors.top: parent.top
            width: parent.width - parent.width * panel.widthContentRatio
            height: parent.height

            Rectangle {
                id: panelCategoryBackground
                anchors.fill: parent
                radius: panel.rad
                color: Qt.lighter(themeManager.foregroundColor, 1.1)
                opacity: 0.8
            }

            Item {
                width: parent.width - panel.rad
                height: parent.height

                Column {
                    height: parent.height * 0.95
                    width: parent.width
                    anchors.centerIn: parent
                    spacing: parent.height * 0.05

                    TreeComponent {
                        text.text: "Mixer"
                        filter: TreeComponentsPanel.Type.Mixer
                    }

                    TreeComponent {
                        text.text: "Sources"
                        filter: TreeComponentsPanel.Type.Mixer
                    }

                    TreeComponent {
                        text.text: "Effects"
                        filter: TreeComponentsPanel.Type.Mixer
                    }

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

            anchors.leftMargin: -panel.rad

            Rectangle {
                id: panelContentBackground
                width: parent.width + panelContent.widthOffset
                height: parent.height
                color: Qt.darker(themeManager.foregroundColor, 1.1)
            }

            ListView {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height * 0.95

                spacing: 20
                model: pluginTable
                clip: true

                delegate: Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.7
                    height: width
                    color: "transparent"
                    border.width: 2
                    border.color: mouseArea.containsMouse ? themeManager.accentColor : "white"
                    radius: 12

                    Image {
                        id: image
                        anchors.centerIn: parent
                        width: parent.width * 0.7
                        height: width
                        source: factoryName ? "qrc:/Assets/Plugins/" + factoryName + ".png" : "qrc:/Assets/Plugins/Default.png"
                    }

                    Glow {
                        anchors.fill: image
                        radius: 2
                        opacity: 0.3
                        samples: 17
                        color: mouseArea.containsMouse ? "white" : "transparent"
                        source: image
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true


                    }
                }
            }
        }

    }

}
