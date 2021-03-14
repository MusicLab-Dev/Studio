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

<<<<<<< HEAD
   ModulesView {
       anchors.fill: parent
   }
=======
    Project {
        id: project
    }
>>>>>>> 3ea0a8b7285c61a42bc1d56e44aee6b8355eee8f

    ThemeManager {
        id: themeManager
        theme: ThemeManager.Classic
    }
}
