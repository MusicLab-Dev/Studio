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
    readonly property color nodeColor: node ? node.color : "black"
    readonly property color nodeDarkColor: Qt.darker(nodeColor, 1.25)
    readonly property color nodeLightColor: Qt.lighter(nodeColor, 1.6)
    readonly property color nodeHoveredColor: Qt.darker(nodeColor, 1.8)
    readonly property color nodePressedColor: Qt.darker(nodeColor, 2.2)
    readonly property color nodeAccentColor: Qt.darker(nodeColor, 1.6)
    property bool hide: false
    property bool closeable: true

    id: controlsFlow
    color: Qt.darker(themeManager.foregroundColor, 1.1)
    height: Math.max(baseHeight, headerRow.height) + 20
    visible: node && !hide

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    Rectangle {
        color: "black"
        width: parent.width
        height: 1
    }

    Row {
        id: headerRow
        height: nodeControlsFlow.height
        spacing: 10
        padding: 10

        DefaultText {
            width: contentView.width * 0.1
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignLeft
            fontSizeMode: Text.HorizontalFit
            font.pixelSize: 30
            wrapMode: Text.Wrap
            text: node ? node.plugin.title : ""
            color: controlsFlow.nodeColor
        }
    }

    Flow {
        id: nodeControlsFlow
        width: parent.width
        padding: 15
        spacing: 20
        anchors.left: headerRow.right
        anchors.right: closeButton.left
        anchors.leftMargin: 10
        anchors.rightMargin: 10
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
        height: Math.min(parent.height / 2, controlsFlow.baseHeight)
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
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
