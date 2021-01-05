import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    property alias modules: modules
    property int componentSelected: 0
    id: grid

    Repeater {
        model: ListModel {
            id: modules
        }

        delegate: Column {
            anchors.fill: grid

            Rectangle {
                height: parent.height * 0.05
                width: parent.width * 0.05
                x: index * parent.width * 0.05
                color: componentSelected === index ? "#001E36" : "#E7E7E7"
                border.color: "black"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        componentSelected = index
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: index
                    color: componentSelected === index ? "white" : "black"
                }
            }

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
            }
        }
    }
}
