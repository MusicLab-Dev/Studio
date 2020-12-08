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
                border.width: 1
                border.color: "black"
                color: componentSelected === index ? "white" : "grey"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        componentSelected = index
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: index
                }
            }

            Loader {
                id: loadedComponent
                height: parent.height
                width: parent.width
                source: path
                z: moduleZ
                visible: componentSelected === index
            }
        }
    }
}
