import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../Default"

Column {
    spacing: 1.0

    Rectangle {
        id: tab
        visible: title !== "+"
        height: parent.height * 0.05
        width: parent.width * 0.20
        x: index * parent.width * 0.20
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
            text: title
            color: componentSelected === index ? "white" : "black"
            visible: true
        }

        DefaultImageButton {
            imgPath: "qrc:/Assets/Close.png"
            height: parent.height / 2
            width: parent.height / 2
            anchors.top: parent.top
            anchors.right: parent.right
            colorDefault: "red"
            showBorder: false
            visible: !(modules.count === 2 && title === "New component")

            onClicked: {
                // check the case if the user wants to remove the componentSelected
                if (componentSelected === modules.count - 2)
                    componentSelected = modules.count - 3

                // check the case if the user wants to the last component
                if (modules.count === 2) {
                    modules.insert(1,
                                   {
                                       title: "New component",
                                       path: "qrc:/EmptyView/EmptyView.qml",
                                       moduleZ: 0
                                   })
                    componentSelected = 0
                }
                modules.remove(index)
            }
        }
    }

    Rectangle {
        id: addTabButton
        visible: title === "+"
        height: parent.height * 0.05
        width: parent.height * 0.05
        x: index * parent.width * 0.20
        color: "#001E36"
        border.color: "black"

        property real barSize: width / 4

        MouseArea {
            anchors.fill: parent
            onClicked: {
                modules.insert(
                            modulesViewContent.modules.count - 1,
                            {title: "New component",
                                path: "qrc:/EmptyView/EmptyView.qml",
                                moduleZ: modulesViewContent.modules.count
                            })
                modulesViewContent.componentSelected = modulesViewContent.modules.count - 2
            }
        }

        Rectangle {
            width: addTabButton.barSize
            height: addTabButton.barSize / 8
            anchors.centerIn: parent
            radius: 20
        }

        Rectangle {
            width: addTabButton.barSize / 8
            height: addTabButton.barSize
            anchors.centerIn: parent
            radius: 20
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
        focus: true
    }
}
