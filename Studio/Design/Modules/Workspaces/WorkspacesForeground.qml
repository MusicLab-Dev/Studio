import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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
            placeholderText: qsTr("Default files")
            color: "white"
            opacity: 0.42
        }
    }

    ColumnLayout {
        id: workspaceForegroundContent
        width: parent.width * 0.8
        height: parent.height * 0.7
        x: (parent.width - width) / 2
        y: workspaceResearchTextInput.y + workspaceResearchTextInput.height * 2

        ListView {
            id: workspacesForegroundListView
            spacing: Math.max(workspaceForeground.height / 30, 20)
            model: workspacesModel
            Layout.fillWidth: true
            Layout.fillHeight: true


            delegate: WorkspaceCard {
                width: workspacesForegroundListView.width

                Component.onCompleted: {
                    if (index === 0)
                        workspaceForeground.actualPath = realPath
                }
            }
        }

        DefaultTextButton {
            text: qsTr("+ NEW WORKSPACE")

            onClicked: folderPicker.open()
        }
    }
}
