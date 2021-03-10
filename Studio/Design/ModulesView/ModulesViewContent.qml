import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Default"

Item {
    property alias modules: modules
    property int componentSelected: 0
    property real tabWidth: width * 0.2

    id: modulesViewContent

    Repeater {
        model: ListModel {
            id: modules

            ListElement {
                title: "New component"
                path: "qrc:/EmptyView/EmptyView.qml"
            }

            ListElement {
                title: "+"
                path: ""
            }
        }

        delegate: Column {
            z: componentSelected === index ? 1 : 0
            anchors.fill: modulesViewContent
            spacing: 1.0

            ModulesViewTab {
                height: parent.height * 0.05
                width: tabWidth
                x: index * parent.width * 0.20
                visible: index !== modules.count - 1
            }

            ModuleViewNewTabButton {
                height: parent.height * 0.05
                width: parent.height * 0.05
                x: index * parent.width * 0.20
                visible: index === modules.count - 1
            }

            Loader {
                id: loadedComponent
                height: parent.height * 0.95
                width: parent.width
                source: path
                visible: componentSelected === index
                focus: true
            }
        }
    }
}
