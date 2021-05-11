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
    title: qsTr("Lexo")
    minimumWidth: 800
    minimumHeight: 600

    Component.onCompleted: {
        width = Screen.desktopAvailableWidth * 0.85
        height = Screen.desktopAvailableHeight * 0.85
        x = Screen.desktopAvailableWidth / 2 - width / 2
        y = Screen.desktopAvailableHeight / 2 - height / 2
    }

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
