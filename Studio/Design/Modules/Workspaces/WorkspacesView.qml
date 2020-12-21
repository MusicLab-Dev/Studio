import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3


import "../../Default"

WorkspacesBackground {
    id: workspaceView

    WorkspacesViewTitle {
        id: workspaceViewTitle
        x: (workspaceForeground.width + (parent.width - workspaceForeground.width) / 2) - width / 2
        y: height
    }

    WorkspacesForeground {
        id: workspaceForeground
        x: parent.parent.x
        y: parent.parent.y
        width: Math.max(parent.width * 0.2, 350)
        height: parent.height

        workspacesModel: ListModel {
            id: workspacesModel

            ListElement {
                name: "Default Workspace"
                path: "./"
            }
        }
    }

    WorkspacesContentArea {
        id: workspaceContentArea
        anchors.top: workspaceViewTitle.bottom
        anchors.left: workspaceForeground.right
        anchors.right: workspaceView.right
        anchors.bottom: workspaceView.bottom
        anchors.margins: parent.width * 0.05
    }


    FileDialog {
        id: folderPicker
        title: "Please choose a workspace folder"
        folder: shortcuts.documents
        selectFolder: true

        onAccepted: {
            workspacesModel.append({
                                       name: "New workspace",
                                       path: folderPicker.fileUrl.toString()
                                   })
        }
    }
}
