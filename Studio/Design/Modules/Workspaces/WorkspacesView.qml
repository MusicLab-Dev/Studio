import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3


import "../../Default"
import "../../Common"

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
    property alias workspacesModel: workspaceForeground.workspacesModel

    id: workspaceView
    visible: false

    WorkspacesViewTitle {
        id: workspaceViewTitle
        x: (workspaceForeground.width + (parent.width - workspaceForeground.width) / 2) - width / 2
        y: height
    }

    TextRoundedButton {
        visible: workspaceContentArea.selectedIndex !== -1 && !workspaceContentArea.selectedIndexIsDir
        id: workspacesViewAcceptButtonText
        x: workspacesViewCloseButtonText.x - width - height
        y: height
        text: "Accept"
        type: 2

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: { workspacesViewAcceptButtonText.buttonHovered = true }

            onExited: { workspacesViewAcceptButtonText.buttonHovered = false }

            onReleased: { workspaceView.acceptAndClose() }
        }
    }

    TextRoundedButton {
        visible: workspaceForeground.parentDepth !== 0
        id: workspacesViewBackButtonText

        width: workspacesViewCloseButtonText.width
        height: workspacesViewCloseButtonText.height
        x: workspaceForeground.width + height
        y: height
        text: "Back"
        type: 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: { workspacesViewBackButtonText.buttonHovered = true }

            onExited: { workspacesViewBackButtonText.buttonHovered = false }

            onReleased: {
                workspaceForeground.actualPath += "/.."
                workspaceForeground.parentDepth -= 1
            }
        }
    }

    TextRoundedButton {
        id: workspacesViewCloseButtonText
        x: workspaceView.width - width - height
        y: height
        text: "Close"
        type: 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: { workspacesViewCloseButtonText.buttonHovered = true }

            onExited: { workspacesViewCloseButtonText.buttonHovered = false }

            onReleased: { workspaceView.cancelAndClose() }
        }
    }

    WorkspacesForeground {
        id: workspaceForeground
        x: parent.parent.x
        y: parent.parent.y
        width: Math.max(parent.width * 0.2, 350)
        height: parent.height

        workspacesModel: app.settings.get("workspacePaths")
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
        readonly property bool cancelKeyboardEventsOnFocus: true

        id: folderPicker
        title: "Please choose a workspace folder"
        folder: shortcuts.documents
        selectFolder: true

        onAccepted: {
            console.log("WorkspacesModel before", workspacesModel)
            var tmp = workspacesModel
            if (tmp === undefined)
                tmp = []
            tmp.push(["New workspace", folderPicker.fileUrl.toString()])
            app.settings.set("workspacePaths", tmp);
            workspacesModel = app.settings.get("workspacePaths")
            console.log("WorkspacesModel after", workspacesModel)
            app.settings.saveValues()
        }
    }
}
