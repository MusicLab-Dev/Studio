import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeManager 1.0
import Application 1.0

import "../ModulesView"
import "../Modules/Board"
import "../Modules/Settings"

Window {
    visible: true
    width: 1280
    height: 720
    title: qsTr("MusicLab")

    Application {
        id: app
    }

    ThemeManager {
        id: themeManager
        theme: ThemeManager.Dark
    }

    ModulesView {
        anchors.fill: parent
    }
}
