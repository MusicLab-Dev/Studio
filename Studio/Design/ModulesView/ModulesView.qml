import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    property alias modulesViewContent: modulesViewContent
    property alias modules: modulesViewContent.modules
    property alias componentSelected: modulesViewContent.componentSelected

    id: modulesView
    color: "#474747"


    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ModulesViewContent {
            id: modulesViewContent
            Layout.preferredHeight: parent.height * 1
            Layout.preferredWidth: parent.width
            // add min / max values
        }
    }


    Shortcut {
        sequence: "Ctrl+T"
        onActivated: {
            modules.insert(
                        modules.count - 1,
                        {
                            title: "New component",
                            path: "qrc:/EmptyView/EmptyView.qml",
                        })
            componentSelected = modules.count - 2
        }
    }

    Shortcut {
        sequence: "Ctrl+W"
        onActivated: {
            var moduleSelectedTmp = componentSelected
            if (componentSelected === modules.count - 2)
                componentSelected = modules.count - 3
            if (modules.count === 2) {
                modules.insert(1,
                               {
                                   title: "New component",
                                   path: "qrc:/EmptyView/EmptyView.qml",
                               })
                componentSelected = 0
            }
            modules.remove(moduleSelectedTmp)
        }
    }


    Shortcut {
        sequence: "Ctrl+Tab"
        onActivated: {
            if (modules.count != 2) {
                if (componentSelected == modules.count - 2)
                    componentSelected = 0
                else
                    componentSelected += 1
            }
        }
    }
}
