import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3


import "../../Default"

WorkspacesBackground {
    function open(multiplePath, accepted, canceled) {
        acceptedCallback = accepted
        canceledCallback = canceled
        fileUrl = ""
        visible = true
    }

    function acceptAndClose() {
        visible = false
        acceptedCallback()
    }

    function cancelAndClose() {
        visible = false
        canceledCallback()
    }

    property var acceptedCallback: function() {}
    property var canceledCallback: function() {}

    property string fileUrl: ""
    property var fileUrls: [fileUrl]

    id: workspaceView
    visible: false

    WorkspacesViewTitle {
        id: workspaceViewTitle
        x: (workspaceForeground.width + (parent.width - workspaceForeground.width) / 2) - width / 2
        y: height
    }

    Rectangle {
        visible: workspaceContentArea.selectedIndex !== -1 && !workspaceContentArea.selectedIndexIsDir
        id: workspacesViewAcceptButton
        width: workspacesViewCloseButton.width
        height: workspacesViewCloseButton.height
        x: workspacesViewCloseButton.x - workspacesViewCloseButton.width - width / 5
        y: height
        color: workspacesViewAcceptButtonText.acceptButtonHovered ? "#31A8FF" : "#1E6FB0"
        radius: 5

        WorkspacesViewAcceptButton {
            id: workspacesViewAcceptButtonText
        }
    }

    Rectangle {
        visible: workspaceForeground.parentDepth !== 0
        id: workspacesViewBackButton
        width: workspacesViewCloseButton.width
        height: workspacesViewCloseButton.height
        x: workspaceForeground.width + height
        y: height
        color: "transparent"
        radius: 5
        border.color: workspacesViewBackButtonText.backButtonHovered ? "#31A8FF" : "#1E6FB0"
        border.width: workspaceForeground.parentDepth !== 0 ? 1 : 0

        WorkspacesViewBackButton {
            id: workspacesViewBackButtonText
        }
    }

    Rectangle {
        id: workspacesViewCloseButton
        width: 70
        height: 30
        x: workspaceView.width - width - height
        y: height
        color: "transparent"
        radius: 5
        border.color: workspacesViewCloseButtonText.closeButtonHovered ? "#31A8FF" : "#1E6FB0"
        border.width: 1

        WorkspacesViewCloseButton {
            id: workspacesViewCloseButtonText
        }
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
                path: ""
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
