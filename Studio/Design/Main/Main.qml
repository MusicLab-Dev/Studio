import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeManager 1.0
import PluginTableModel 1.0
import Application 1.0
import NodeModel 1.0
import BoardManager 1.0
import EventDispatcher 1.0
import DevicesModel 1.0

import "../Common"
import "../Modules"
import "../Workspaces"

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
    title: qsTr("Lexo")
    minimumWidth: 800
    minimumHeight: 600

    Component.onCompleted: {
        Screen
        width = Screen.width * 0.85
        height = Screen.height * 0.85
        x = Screen.width / 2 - width / 2
        y = Screen.height / 2 - height / 2
    }

    Application {
        property NodeModel partitionNodeCache: null
        property int partitionIndexCache: -1
        property NodeModel plannerNodeCache: null
        property var plannerNodesCache: []
        property var currentPlayer: null

        id: app
    }

    ThemeManager {
        property color semiAccentColor: "#338DCF" // @todo add this to ThemeManager

        id: themeManager
        theme: ThemeManager.Dark
    }

    BoardManager {
        id: boardManager
    }

    PluginTableModel {
        id: pluginTable
    }

    EventDispatcher {
        property bool cancelEvents: false

        id: eventDispatcher

        keyboardListener.enabled: {
            !cancelEvents && (mainWindow.activeFocusItem ? !(mainWindow.activeFocusItem["cancelKeyboardEventsOnFocus"] === true) : true)
        }

        boardListener.boardManager: boardManager
    }

    DevicesModel {
        id: devicesModel
    }

    ModulesView {
        enabled: !globalTextField.visible
        anchors.fill: parent
    }

    GlobalTextField {
        id: globalTextField
    }
}
