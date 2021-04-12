import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default"

Item {
    property alias modules: modules
    property int componentSelected: 0
    property real tabWidth: width / Math.max(modules.count, 5)
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

    Repeater {
        id: moduleRepeater
        model: ListModel {
            id: modules

            Component.onCompleted: {
                modules.append({
                    title: "New component",
                    path: "qrc:/EmptyView/EmptyView.qml",
                    callback: nullCallback
                })
                modules.append({
                    title: "+",
                    path: "",
                    callback: nullCallback
                })
            }
        }

        onCountChanged: {
            if (count === 1 && modules.get(0).path === "") {
                modules.append({
                    title: "New component",
                    path: "qrc:/EmptyView/EmptyView.qml",
                    callback: nullCallback
                })
            }

        }

        delegate: Column {
            property var moduleItem: loadedComponent.item

            z: componentSelected === index ? 1 : 0
            anchors.fill: modulesViewContent
            spacing: 1.0

            ModulesViewTab {
                height: parent.height * 0.05
                width: tabWidth
                z: 100
                visible: index !== modules.count - 1
            }

            ModuleViewNewTabButton {
                height: parent.height * 0.05
                width: parent.height * 0.05
                x: index * tabWidth
                z: 100
                visible: index === modules.count - 1
            }

            Loader {
                id: loadedComponent
                height: parent.height * 0.95
                width: parent.width
                source: path
                visible: componentSelected === index
                focus: true

                onLoaded: {
                    if (path === "")
                        return
                    loadedComponent.item.moduleIndex = index
                    callback.target = loadedComponent.item
                    callback.trigger()
                }
            }
        }
    }
}
