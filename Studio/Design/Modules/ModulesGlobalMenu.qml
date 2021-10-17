
import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

DefaultMenuButton {
    function newProject() {
        modulesView.removeAllModules()
        app.project.clear()
        app.project.name = qsTr("My Project")
    }

    function load(path) {
        modulesView.removeAllModules()
        if (oldCompatibility)
            app.project.loadOldCompatibilityFrom(path)
        else
            app.project.loadFrom(path)
    }

    function openProject() {
        oldCompatibility = false
        loadFileDialog.open()
    }

    function openOldCompatibilityProject() {
        oldCompatibility = true
        loadFileDialog.open()
    }

    function exportProject() {
        exportManager.open()
    }

    function save() {
        if (app.project.path === "")
            saveAs()
        else
            app.project.save()
    }

    function saveAs() {
        saveFileDialog.open()
    }

    function settings() {
        modulesView.settingsView.open()
    }

    property bool oldCompatibility: false

    id: menuButton
    height: parent.height * 0.05
    width: parent.height * 0.05

    onReleased: globalMenu.popup()

    Connections {
        target: eventDispatcher

        function onOpenProject(pressed) { if (pressed) menuButton.openProject() }
        function onExportProject(pressed) { if (pressed) menuButton.exportProject() }
        function onSave(pressed) { if (pressed) menuButton.save(); }
        function onSaveAs(pressed) { if (pressed) menuButton.saveAs(); }
        function onSettings(pressed) { if (pressed) menuButton.settings(); }
    }

    DefaultMenu {
        id: globalMenu

        Action {
            text: qsTr("New Project")
            onTriggered: menuButton.newProject()
        }

        Action {
            text: qsTr("Save")
            onTriggered: menuButton.save()
        }

        Action {
            text: qsTr("Save Project As...")
            onTriggered: menuButton.saveAs()
        }

        Action {
            text: qsTr("Open Project File...")
            onTriggered: menuButton.openProject()
        }

        Action {
            text: qsTr("Open Old Compatibility Project File...")
            onTriggered: menuButton.openOldCompatibilityProject()
        }

        Action {
            text: qsTr("Export")
            onTriggered: menuButton.exportProject()
        }

        DefaultMenu {
            title: "Open Template..."

            Action {
                text: qsTr("Basic")
                onTriggered: {
                    menuButton.load(":/Templates/TEMPLATE_basic")
                    app.project.path = ""
                }
            }

            Action {
                text: qsTr("Demo")
                onTriggered: {
                    menuButton.load(":/Templates/TEMPLATE_demo")
                    app.project.path = ""
                }
            }
        }

        Action {
            text: qsTr("Preferences")
            onTriggered: menuButton.settings()
        }

        Action {
            text: qsTr("Keyboard shortcuts")
            onTriggered: keyboardShortcutsView.open()
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
        title: qsTr("Load a project file")
        folder: shortcuts.home
        nameFilters: [ "All files (*)" ]
        selectExisting: true
        visible: false

        onAccepted: {
            var path = mainWindow.urlToPath(fileUrl.toString())
            menuButton.load(path)
        }

        onRejected: close()
    }
}
