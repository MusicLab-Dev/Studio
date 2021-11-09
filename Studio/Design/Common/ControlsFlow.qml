import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default/"
import "../Common/"

import ThemeManager 1.0
import NodeModel 1.0
import PluginModel 1.0

Rectangle {
    property alias node: controlsFlowBase.node
    property alias controlsFlowBase: controlsFlowBase
    property var menuFunc: null
    property alias headerRow: headerRow
    property alias menuButton: menuButton

    property real baseHeight: 60
    property real baseMargin: 20

    id: controlsFlow
    color: themeManager.backgroundColor
    implicitHeight: Math.max(baseHeight, controlsFlowBase.height) + baseMargin

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    RowLayout {
        id: headerRow
        height: parent.height
        width: parent.width * 0.15
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PluginFactoryImageButton {
                id: menuButton
                width: height
                height: Math.min(parent.height / 2, controlsFlow.baseHeight)
                scaleFactor: 1
                anchors.centerIn: parent
                name: node ? node.plugin.title : ""
                colorDefault: controlsFlowBase.nodeColor
                colorHovered: controlsFlowBase.nodeHoveredColor
                colorOnPressed: controlsFlowBase.nodePressedColor
                playing: contentView.playerBase.isPlayerRunning

                onPressed: {
                    if (menuFunc)
                        menuFunc()
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.65

            DefaultText {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.HorizontalFit
                font.pixelSize: 30
                color: controlsFlowBase.nodeColor
                text: node ? qsTr(node.name + "'s controls") : ""
                wrapMode: Text.Wrap
            }
        }
    }

    Rectangle {
        id: separator
        anchors.left: headerRow.right
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height * 0.8
        color: "black"
    }

    ControlsFlowBase {
        id: controlsFlowBase
        anchors.left: separator.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
