import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeManager 1.0
import PluginTableModel 1.0
import Application 1.0
import NodeModel 1.0
import BoardManager 1.0
import EventDispatcher 1.0

import "../ModulesView"
import "../Modules/Workspaces"

Window {

    function urlToPath(urlString) {
        var s
        if (urlString.startsWith("file:///")) {
            var k = urlString.charAt(9) === ':' ? 8 : 7
            s = urlString.substring(k)
        } else {
            s = urlString
        }
        return s;
    }

    id: mainWindow
    visible: true
    width: 1280
    height: 720
    title: qsTr("Lexo")
    minimumWidth: 800
    minimumHeight: 600

    Application {
        property NodeModel partitionNodeCache: null
        property int partitionIndexCache: -1
        property var currentPlayer: null

        id: app
    }

    ThemeManager {
        id: themeManager
        theme: ThemeManager.Dark
    }

    BoardManager {
        id: boardManager
    }

    ModulesView {
        anchors.fill: parent
    }

    PluginTableModel {
        id: pluginTable
    }

    EventDispatcher {
        id: eventDispatcher

        keyboardListener.enabled: {
            mainWindow.activeFocusItem ? !(mainWindow.activeFocusItem["cancelKeyboardEventsOnFocus"] === true) : true
        }
    }
}
