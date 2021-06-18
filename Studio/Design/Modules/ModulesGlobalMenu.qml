
import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

DefaultMenuButton {
    function load(path) {
        modulesView.removeAllModules()
        app.project.loadFrom(path)
    }

    id: menuButton
    height: parent.height * 0.05
    width: parent.height * 0.05
    imageFactor: 0.75
    rect.color: themeManager.foregroundColor
    rect.border.color: "black"
    rect.border.width: 1

    onReleased: globalMenu.popup()

    DefaultMenu {
        id: globalMenu

        Action {
            text: qsTr("New Project")
            onTriggered: {
                modulesView.removeAllModules()
                app.project.clear()
            }
        }

        Action {
            text: qsTr("Save")
            onTriggered: {
                if (app.project.path === "")
                    saveFileDialog.open()
                else
                    app.project.save()
            }
        }

        Action {
            text: qsTr("Save Project As...")
            onTriggered: saveFileDialog.open()
        }

        Action {
            text: qsTr("Open Project File...")
            onTriggered: loadFileDialog.open()
        }

        DefaultMenu {

            title: "Open Template..."

            Action {
                text: "Basic"
                onTriggered: {
                    menuButton.load(":/Templates/TEMPLATE_basic")
                    app.project.path = ""
                }
            }

        }

        Action {
            text: qsTr("Preferences")
            onTriggered: modulesView.settingsView.open()
        }

        Action {
            text: qsTr("Boards")
            onTriggered: modulesView.boardsView.open()
        }

        Action {
            text: qsTr("Exit")
            onTriggered: Qt.quit()
        }
    }

    DefaultFileDialog {
        id: saveFileDialog
        title: qsTr("Save a project file")
        folder: shortcuts.home
        nameFilters: [ "All files (*)" ]
        selectExisting: false
        visible: false

        onAccepted: {
            app.project.saveAs(mainWindow.urlToPath(fileUrl.toString()))
            close()
        }

        onRejected: close()
    }

    DefaultFileDialog {
        id: loadFileDialog
        title: qsTr("Choose a file")
        folder: shortcuts.home
        nameFilters: [ "All files (*)" ]
        selectExisting: true
        visible: false

        onAccepted: menuButton.load(mainWindow.urlToPath(fileUrl.toString()))

        onRejected: close()
    }
}