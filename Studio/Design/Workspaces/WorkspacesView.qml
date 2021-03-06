import QtQuick 2.15
import QtQuick.Controls 2.15


import "../Default"
import "../Common"

WorkspacesBackground {
    function open(multiplePath, accepted, canceled) {
        acceptedCallback = accepted
        canceledCallback = canceled
        fileUrl = ""
        visible = true
    }

    function acceptAndClose() {
        var accepted = acceptedCallback
        visible = false
        acceptedCallback = null
        canceledCallback = null
        if (accepted)
            accepted()
    }

    function cancelAndClose() {
        var canceled = canceledCallback
        visible = false
        acceptedCallback = null
        canceledCallback = null
        if (canceled)
            canceled()
    }

    property var acceptedCallback: function() {}
    property var canceledCallback: function() {}

    property string fileUrl: ""
    property var fileUrls: [fileUrl]
    property alias workspacesModel: workspaceForeground.workspacesModel
    property string lastSelectedWorkspace: ""
    property alias searchFilter: workspaceForeground.searchFilter

    id: workspaceView
    visible: false

    Text {
        id: workspaceViewTitle
        x: (workspaceForeground.width + (parent.width - workspaceForeground.width) / 2) - width / 2
        y: height
        color: "lightgrey"
        font.pointSize: 34
        text: lastSelectedWorkspace
    }

    TextRoundedButton {
        visible: workspaceContentArea.selectedIndex !== -1 && !workspaceContentArea.selectedIndexIsDir
        id: workspacesViewAcceptButtonText
        x: workspacesViewCloseButtonText.x - width - height
        y: height
        text: "Accept"
        hoverOnText: false

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: { workspacesViewAcceptButtonText.buttonHovered = true }

            onExited: { workspacesViewAcceptButtonText.buttonHovered = false }

            onReleased: {
                workspaceView.fileUrl = workspaceContentArea.selectedPath
                workspaceView.acceptAndClose()
            }
        }
    }

    TextRoundedButton {
        id: workspacesViewBackButtonText
        visible: workspaceForeground.parentDepth !== 0
        width: workspacesViewCloseButtonText.width
        height: workspacesViewCloseButtonText.height
        x: workspaceForeground.width + height
        y: height
        text: "Back"

        onReleased: {
            workspaceForeground.actualPath += "/.."
            workspaceForeground.parentDepth -= 1
        }
    }

    TextRoundedButton {
        id: workspacesViewCloseButtonText
        x: workspaceView.width - width - height
        y: height
        text: "Close"

        onReleased: workspaceView.cancelAndClose()
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


    DefaultFileDialog {
        readonly property bool cancelKeyboardEventsOnFocus: true

        id: folderPicker
        title: "Please choose a workspace folder"
        folder: shortcuts.documents
        selectFolder: true

        onAccepted: {
            var tmp = workspacesModel
            if (tmp === undefined)
                tmp = []
            var path = folderPicker.fileUrl.toString()
            var nameStartIdx = path.lastIndexOf('/')
            var name = ""
            if (nameStartIdx === path.length - 1)
                nameStartIdx = path.lastIndexOf('/', 1)
            if (nameStartIdx === -1)
                name = path
            else
                name = path.substr(nameStartIdx + 1)
            tmp.push([name, path])
            app.settings.set("workspacePaths", tmp);
            workspacesModel = app.settings.get("workspacePaths")
            app.settings.saveValues()
        }
    }
}
