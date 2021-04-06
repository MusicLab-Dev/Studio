import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeManager 1.0
import PluginTableModel 1.0
import Application 1.0
import NodeModel 1.0

import "../ModulesView"
import "../Modules/Board"

Window {
    visible: true
    width: 1280
    height: 720
    title: qsTr("Lexo")
    minimumWidth: 800
    minimumHeight: 600

    Application {
        property NodeModel partitionNodeCache: null
        property int partitionIndexCache: -1

        id: app
    }

    ThemeManager {
        id: themeManager
        theme: ThemeManager.Dark
    }

    ModulesView {
        anchors.fill: parent
    }

    PluginTableModel {
        id: pluginTable
    }
}
