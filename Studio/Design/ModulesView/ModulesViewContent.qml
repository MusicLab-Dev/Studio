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
                addButton: true
                moduleZ: 0
                path: "qrc:/EmptyView/EmptyView.qml"
            }
        }

        delegate: Column {
            anchors.fill: grid

            Rectangle {
                height: parent.height * 0.05
                width: parent.width * 0.05
                x: (addButton ? modules.count - 1 : index - 1) * parent.width * 0.05
                color: componentSelected === index ? "#001E36" : "#E7E7E7"
                border.color: "black"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (addButton) {
                            modulesViewContent.modules.append({path: tmp ? "qrc:/SequencerView/SequencerView.qml" : "qrc:/PlaylistView/PlaylistView.qml", moduleZ: modulesViewContent.modules.count, addButton: false})
                            modulesViewContent.componentSelected = modulesViewContent.modules.count - 1
                            tmp = !tmp
                        } else
                            componentSelected = index
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    visible: addButton
                    color: "white"
                    border.color: "black"

                    Rectangle {
                        anchors.centerIn: parent
                        height: parent.height * 0.5
                        width: parent.width * 0.05
                        color: "#001E36"
                        radius: 10
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        height: parent.height * 0.08
                        width: parent.width * 0.3
                        color: "#001E36"
                        radius: 10
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: index
                    color: componentSelected === index ? "white" : "black"
                    visible: !addButton
                }

                DefaultImageButton {
                    imgPath: "qrc:/Assets/Close.png"
                    height: parent.height / 2
                    width: parent.height / 2
                    anchors.top: parent.top
                    anchors.right: parent.right
                    colorDefault: "red"
                    showBorder: false
                    visible: !addButton

                    onClicked: {

                    }
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
