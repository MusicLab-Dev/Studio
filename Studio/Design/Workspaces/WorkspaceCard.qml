import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1

import "../Default"

Rectangle {
    property string name: modelData[0]
    property string path: modelData[1]
    property bool expanded: workspaceFoldButton.activated
    property bool editModeEnabled: false
    property string realPath: path === "" ? StandardPaths.writableLocation(StandardPaths.HomeLocation) : path
    property real spacing: 4
    property alias workspaceName: workspaceName

    id: workspaceCard
    height: cardHeader.height + (expanded ? folderColumnView.height + spacing : 0)
    color: themeManager.foregroundColor
    radius: 15

    onExpandedChanged: {
        if (folderColumnView.model === 0)
            folderColumnView.loadModel()
    }

    Item {
        id: cardHeader
        width: parent.width
        height: Math.max(workspaceForeground.height / 14, 50)

        Component.onCompleted: {
            if (index === 0) {
                workspaceFoldButton.activated = true
                workspaceView.lastSelectedWorkspace = workspaceName.text
            }
        }

        MouseArea {
            anchors.fill: parent

            onPressed: {
                workspaceForeground.actualPath = realPath
                parentDepth = 0
                workspaceView.lastSelectedWorkspace = workspaceName.text
            }
        }

        Row {
            anchors.fill: parent
            anchors.margins: spacing
            spacing: 10

            DefaultFoldButton {
                id: workspaceFoldButton
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height * 0.6
            }

            DefaultTextInput {
                id: workspaceName
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - parent.spacing * 3 - workspaceFoldButton.width * 3
                color: "#FFFFFF"
                opacity: enabled ? 1 : 0.5
                text: name
                enabled: editModeEnabled

                background: Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                }

                onEditingFinished: {
                    console.log("Editing finished")
                    var tmpModel = workspaceView.workspacesModel
                    tmpModel[index][0] = text
                    app.settings.set("workspacePaths", tmpModel);
                    app.settings.saveValues()
                }
            }

            DefaultImageButton {
                id: editBtn
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height * 0.6
                source: "qrc:/Assets/EditWorkspaceName.png"
                colorDefault: editModeEnabled ? themeManager.accentColor : "grey"
                showBorder: false
                scaleFactor: 1

                onReleased: editModeEnabled = !editModeEnabled
            }

            DefaultImageButton {
                id: deleteBtn
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height * 0.6
                colorDefault: "red"
                source: "qrc:/Assets/Close.png"
                showBorder: false
                scaleFactor: 1

                onReleased: {
                    var tmpModel = workspaceView.workspacesModel
                    console.log(tmpModel)
                    tmpModel.splice(index, 1)
                    app.settings.set("workspacePaths", tmpModel);
                    app.settings.saveValues()
                    workspaceView.workspacesModel = tmpModel
                }
            }
        }
    }

    FolderColumnView {
        id: folderColumnView
        visible: workspaceCard.expanded
        width: parent.width
        anchors.top: cardHeader.bottom
        anchors.topMargin: workspaceCard.spacing
        bottomPadding: parent.height * 0.05
        realPath: workspaceCard.realPath
    }
}
