import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default/"
import "../Common/"

import ThemeManager 1.0
import NodeModel 1.0
import PluginModel 1.0

Flow {
    // Node related
    property NodeModel node
    readonly property color nodeColor: node ? node.color : "grey"
    readonly property color nodeDarkColor: Qt.darker(nodeColor, 1.25)
    readonly property color nodeLightColor: Qt.lighter(nodeColor, 1.6)
    readonly property color nodeHoveredColor: Qt.darker(nodeColor, 1.8)
    readonly property color nodePressedColor: Qt.darker(nodeColor, 2.2)
    readonly property color nodeAccentColor: Qt.darker(nodeColor, 1.6)

    // Controls repeater
    property alias controlsRepeater: controlsRepeater

    id: controlsFlowBase
    padding: 15
    spacing: 20

    Repeater {
        id: controlsRepeater
        model: node ? node.plugin : null

        delegate: ControlsFlowLoader {
            id: delegateLoader
            color: node.color
        }
    }
}
