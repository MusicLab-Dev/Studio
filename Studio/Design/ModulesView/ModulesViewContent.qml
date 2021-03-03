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

        delegate: Column {
            anchors.fill: grid
            spacing: 1.0

            ModulesViewTab {}

            ModuleViewNewTabButton {}

            /** Todo: improve the stability of loaded modules
                            1st way : Make a setting to enable 1 loader per ModulesView
                            2nd way : Dynamically unload unused tabs by time
                            3nd way: Mix both 1st and 2nd
                        */

            Loader {
                id: loadedComponent
                height: parent.height * 0.95
                width: parent.width
                source: path
                z: moduleZ
                visible: componentSelected === index
                focus: true
            }
        }
    }

}
