import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Default"

Item {
    property alias modules: modules
    property int componentSelected: 0
    property bool tmp: true
    id: grid

    Repeater {
        model: ListModel {
            id: modules

            ListElement {
                title: "New component"
                path: "qrc:/EmptyView/EmptyView.qml"
                moduleZ: 0
            }

            ListElement {
                title: "+"
                path: ""
                moduleZ: 0
            }
        }

        delegate: ModulesViewTab {
            anchors.fill: grid
        }
    }

}
