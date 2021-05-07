import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.0

import "../Default"

Item {
    property alias modules: modules
    property int componentSelected: 0
    property real tabWidth: (width - newTabButton.width - menuButton.width) / Math.max(modules.count, 5)
    property alias nullCallback: nullCallback
    property alias sequencerPartitionNodeCallback: sequencerPartitionNodeCallback
    property alias sequencerNewPartitionNodeCallback: sequencerNewPartitionNodeCallback

    function getModule(index) {
        return moduleRepeater.itemAt(index).moduleItem
    }

    id: modulesViewContent

    Action {
        property var target: null

        id: nullCallback
    }

    Action {
        property var target: null

        id: sequencerPartitionNodeCallback

        onTriggered: {
            target.loadPartitionNode()
        }
    }

    Action {
        property var target: null

        id: sequencerNewPartitionNodeCallback

        onTriggered: {
            target.loadNewPartitionNode()
        }
    }

    DefaultMenuButton {
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
                    modulesView.removeAllComponents()
                    app.project.clear()
                    componentSelected = 0
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

            Action {
                text: qsTr("Preferences")
                onTriggered: modulesView.settingsView.open()
            }

            Action {
                text: qsTr("Exit")
                onTriggered: Qt.quit()
            }
        }

        FileDialog {
            id: saveFileDialog
            title: qsTr("Save a project file")
            folder: shortcuts.home
            nameFilters: [ "All files (*)" ]
            selectExisting: false
            onAccepted: {
                app.project.saveAs(mainWindow.urlToPath(fileUrl.toString()))
                close()
            }
            onRejected: close()
            Component.onCompleted: visible = false
        }

        FileDialog {
            id: loadFileDialog
            title: qsTr("Choose a file")
            folder: shortcuts.home
            nameFilters: [ "All files (*)" ]
            selectExisting: true
            onAccepted: {
                modulesView.removeAllComponentsWithoutEmptyView()
                app.project.loadFrom(mainWindow.urlToPath(fileUrl.toString()))
                modules.insert(0, {
                        title: "Playlist",
                        path: "qrc:/PlaylistView/PlaylistView.qml",
                        callback: modulesViewContent.nullCallback
                    })
                componentSelected = 0
                close()
            }
            onRejected: close()
            Component.onCompleted: visible = false
        }

    }

    Repeater {
        id: moduleRepeater
        model: ListModel {
            function removeModule(idx) {
                remove(idx)
                for (var i = 0; i < modules.count; ++i)
                    modulesViewContent.getModule(i).moduleIndex = i
            }

            id: modules

            Component.onCompleted: {
                modules.append({
                    title: "New component",
                    path: "qrc:/EmptyView/EmptyView.qml",
                    callback: nullCallback
                })
            }
        }

        // onCountChanged: {
        //     if (count === 1 && modules.get(0).path === "") {
        //         modules.append({
        //             title: "New component",
        //             path: "qrc:/EmptyView/EmptyView.qml",
        //             callback: nullCallback
        //         })
        //     }
        // }

        delegate: Column {
            property var moduleItem: loadedComponent.item

            z: componentSelected === index ? 1 : 0
            anchors.fill: modulesViewContent
            spacing: 1.0

            ModulesViewTab {
                id: moduleTab
                height: parent.height * 0.05
                width: tabWidth
                visible: index !== modules.count
                tabTitle: loadedComponent.item ? loadedComponent.item.moduleName : qsTr("Loading")
            }

            Loader {
                id: loadedComponent
                height: parent.height * 0.95
                width: parent.width
                source: path
                visible: componentSelected === index
                focus: true
                clip: true

                onVisibleChanged: {
                    focus = true
                }

                onLoaded: {
                    if (path === "")
                        return
                    loadedComponent.item.moduleIndex = index
                    callback.target = loadedComponent.item
                    callback.trigger()
                    focus = true
                    item.focus = true
                }
            }
        }
    }

    ModuleViewNewTabButton {
        id: newTabButton
        height: parent.height * 0.05
        width: parent.height * 0.05
        x: menuButton.width + modules.count * tabWidth
    }
}
