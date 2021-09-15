import QtQuick 2.15
import QtQml 2.15

import NodeModel 1.0
import PluginModel 1.0
import PluginTableModel 1.0

import "../Default"
import "../Common"

Rectangle {
    width: 10
    height: 10
    visible: treeView.player.isPlayerRunning
    radius: 12
}
