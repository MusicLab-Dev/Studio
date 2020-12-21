import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"


Rectangle {
    property var workspacesModel
    property string actualPath: ""

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
            id: workspacesForegroundListView
            anchors.fill: parent
            spacing: Math.max(workspaceForeground.height / 30, 20)
            model: workspacesModel

            delegate: WorkspaceCard {
                width: workspacesForegroundListView.width
                height: Math.max(workspaceForeground.height / 14, 50)

                MouseArea {
                    anchors.fill: parent
                    onPressed: actualPath = path
                }
            }

            DefaultTextButton {
                y: {
                    if (workspacesForegroundListView.height >= workspacesForegroundListView.count * Math.max(workspaceForeground.height / 14, 50) + workspacesForegroundListView.count * Math.max(workspaceForeground.height / 30, 20))
                        workspacesForegroundListView.count * Math.max(workspaceForeground.height / 14, 50) + workspacesForegroundListView.count * Math.max(workspaceForeground.height / 30, 20)
                    else
                        workspacesForegroundListView.height * 1.04
                }
                text: qsTr("+ NEW WORKSPACE")

                onClicked: folderPicker.open()
            }
        }
    }
}
