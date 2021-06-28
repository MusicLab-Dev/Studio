import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Tree"

Item {
    function getModule(idx) {
        if (idx < 0) {
            switch (idx) {
            case -1:
                return treeView
            default:
                return null
            }
        } else {
            var instance = modulesLoadersRepeater.itemAt(idx)
            return instance ? instance.item : null
        }
    }

    property alias selectedModule: modulesTabs.selectedModule
    property alias staticTabCount: modulesTabs.staticTabCount
    property alias totalTabCount: modulesTabs.totalTabCount

    id: modulesContent

    ModulesTabs {
        id: modulesTabs
        z: 100
    }

    TreeView {
        id: treeView
        visible: modulesContent.selectedModule === moduleIndex
        moduleIndex: -1

        Binding on y {
            when: visible
            value: modulesTabs.height
            restoreMode: Binding.RestoreNone
        }

        Binding on width {
            when: visible
            value: parent.width
            restoreMode: Binding.RestoreNone
        }

        Binding on height {
            when: visible
            value: parent.height - modulesTabs.height
            restoreMode: Binding.RestoreNone
        }
    }

    Repeater {
        id: modulesLoadersRepeater
        model: modulesView.modules

        delegate: Loader {
            readonly property int moduleIndex: index
            readonly property bool isSelectedModule: modulesContent.selectedModule === moduleIndex

            id: moduleLoader
            visible: isSelectedModule
            enabled: isSelectedModule
            focus: true
            source: path

            onVisibleChanged: focus = true

            onModuleIndexChanged: {
                if (item)
                    item.moduleIndex = moduleIndex
            }

            onLoaded: {
                if (path === "")
                    return
                item.moduleIndex = moduleIndex
                callback.target = item
                callback.trigger()
                focus = true
                item.focus = true
            }

            Binding on y {
                when: visible
                value: modulesTabs.height
                restoreMode: Binding.RestoreNone
            }

            Binding on width {
                when: visible
                value: parent.width
                restoreMode: Binding.RestoreNone
            }

            Binding on height {
                when: visible
                value: parent.height - modulesTabs.height
                restoreMode: Binding.RestoreNone
            }
        }
    }
}