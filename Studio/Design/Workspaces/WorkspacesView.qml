import QtQuick 2.15
import QtQuick.Controls 2.15


import "../Default"
import "../Common"

Item {
    function open(multiplePath, accepted, canceled) {
        acceptedCallback = accepted
        canceledCallback = canceled
        fileUrl = ""
        visible = true
        openAnim.start()
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

    ParallelAnimation {
        id: openAnim
        PropertyAnimation { target: workspaceWindow; property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCirc }
        PropertyAnimation { target: background; property: "opacity"; from: 0; to: background.opacityMax; duration: 100; }
    }

    BackgroundPopup {
        id: background
        anchors.fill: parent
    }

    ContentPopup {
        id: workspaceWindow

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
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.right: workspacesViewCloseButtonText.right
            anchors.rightMargin: 30
            text: "Back"

            onReleased: {
                workspaceForeground.actualPath += "/.."
                workspaceForeground.parentDepth -= 1
            }
        }

        TextRoundedButton {
            id: workspacesViewCloseButtonText
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.right: parent.right
            anchors.rightMargin: 30
            text: "Close"

            onReleased: workspaceView.cancelAndClose()
        }

        WorkspacesForeground {
            id: workspaceForeground
            anchors.top: parent.top
            anchors.left: parent.left
            width: Math.max(parent.width * 0.2, 350)
            height: parent.height

            workspacesModel: app.settings.get("workspacePaths")
        }

        WorkspacesContentArea {
            id: workspaceContentArea
            anchors.top: workspaceViewTitle.top
            anchors.topMargin: parent.height * 0.15
            anchors.left: workspaceForeground.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
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
}
