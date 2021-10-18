import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0

import NodeModel 1.0

import "../Default/"
import "../Common/"

import NodeModel 1.0
import PluginModel 1.0

Rectangle {
    property NodeModel node
    readonly property real baseHeight: 60
    readonly property color nodeColor: node ? node.color : color
    readonly property color nodeDarkColor: Qt.darker(nodeColor, 1.25)
    readonly property color nodeLightColor: Qt.lighter(nodeColor, 1.6)
    readonly property color nodeHoveredColor: Qt.darker(nodeColor, 1.8)
    readonly property color nodePressedColor: Qt.darker(nodeColor, 2.2)
    readonly property color nodeAccentColor: Qt.darker(nodeColor, 1.6)

    // Hide states
    property bool hide: false
    property bool requiredVisibility: node && !hide
    property bool closeable: true

    id: controlsFlow
    color: themeManager.contentColor
    implicitHeight: Math.max(baseHeight, headerRow.height) + 20

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    RowLayout {
        id: headerRow
        height: nodeControlsFlow.height
        width: parent.width * 0.15
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left

        Item {
            id: icon
            Layout.fillHeight: true
            Layout.fillWidth: true

            PluginFactoryImage {
                width: height
                height: parent.height * 0.75
                anchors.centerIn: parent
                name: node ? node.plugin.title : ""
                color: node ? node.color : "black"
                playing: contentView.playerBase.isPlayerRunning
            }
        }

        Item {
            id: name
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
                wrapMode: Text.Wrap
                text: node ? qsTr(node.name + "'s controls") : ""
                color: controlsFlow.nodeColor
            }
        }

    }

    Rectangle {
        anchors.left: headerRow.right
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height * 0.8
        color: "black"
    }

    Flow {
        id: nodeControlsFlow
        width: parent.width
        padding: 15
        spacing: 20
        anchors.left: headerRow.right
        anchors.right: closeButton.left
        anchors.leftMargin: parent.width * 0.01
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            id: nodeControlsRepeater
            model: node ? node.plugin : null

            delegate: Loader {
                id: delegateLoader

                source: {
                    switch (controlType) {
                    case PluginModel.Boolean:
                        return "qrc:/Common/PluginControls/BooleanControl.qml"
                    case PluginModel.Integer:
                        return "qrc:/Common/PluginControls/IntegerControl.qml"
                    case PluginModel.Floating:
                        return "qrc:/Common/PluginControls/FloatingControl.qml"
                    case PluginModel.Enum:
                        return "qrc:/Common/PluginControls/EnumControl.qml"
                    default:
                        return ""
                    }
                }

                onLoaded: {
                    item.accentColor = node.color
                }
            }
        }
    }

    DefaultImageButton {
        id: closeButton
        width: height
        height: Math.min(parent.height * 0.25, controlsFlow.baseHeight)
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 35
        source: "qrc:/Assets/Close.png"
        showBorder: false
        scaleFactor: 1
        colorDefault: controlsFlow.nodeColor
        colorHovered: controlsFlow.nodeHoveredColor
        colorOnPressed: controlsFlow.nodePressedColor
        visible: controlsFlow.closeable

        onReleased: controlsFlow.hide = true
    }
}
