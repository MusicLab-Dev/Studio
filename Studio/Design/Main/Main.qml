import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import ThemeManager 1.0
import Application 1.0

import "../ModulesView"

Window {
    property alias themeManager: themeManager

    visible: true
    width: 1280
    height: 720
    title: qsTr("MusicLab")

    Application {
        id: app
    }

   ModulesView {
       anchors.fill: parent
   }

    ThemeManager {
        id: themeManager
        theme: ThemeManager.Classic
    }
}
