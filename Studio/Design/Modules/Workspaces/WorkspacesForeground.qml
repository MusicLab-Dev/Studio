import QtQuick 2.15
import QtQuick.Controls 2.15


import "../../Default"


Rectangle {
    id: workspaceForeground
    color: "#0D2D47"
    radius: 30

    Rectangle {
        width: parent.width * 0.1
        height: parent.height
        anchors.right: parent.right
        color: parent.color
    }

    Item {
        id: workspaceResearchTextInput
        width: parent.width * 0.8
        height : parent.height * 0.05
        x: (parent.width - width) / 2
        y: (parent.height - height) / 10

        DefaultTextInput {
            anchors.fill: parent
            placeholderText: "Fichiers par défault"
            color: "white"
            opacity: 0.42
        }
    }


    Item {
        id: workspaceForegroundContent
        width: parent.width * 0.8
        height: parent.height * 0.7
        x: (parent.width - width) / 2
        y: workspaceResearchTextInput.y + workspaceResearchTextInput.height * 2

        ListView {
            id: listView
            anchors.fill: parent
            spacing: Math.max(workspaceForeground.height / 30, 20)
            model: ListModel {
                id: listModel
                ListElement {
                    name: "Default Workspace"
                    path: "./"
                }
            }

            delegate: WorkspaceCard {
                width: listView.width
                height: Math.max(workspaceForeground.height / 14, 50)
            }

            DefaultTextButton {
                y: {
                    if (listView.height >= listView.count * Math.max(workspaceForeground.height / 14, 50) + listView.count * Math.max(workspaceForeground.height / 30, 20))
                        listView.count * Math.max(workspaceForeground.height / 14, 50) + listView.count * Math.max(workspaceForeground.height / 30, 20)
                    else
                        listView.height * 1.04
                }
                text: qsTr("+ NEW WORKSPACE")

                onClicked: {
                    listModel.append({
                                         name: "New workspace",
                                         path: "./"
                                     })
                }

            }
        }


    }
}
