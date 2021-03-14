import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1

import '../../Default'

Rectangle {
    property bool expanded: workspaceFoldButton.activated
    property bool editModeEnabled: false
    property string realPath: path === "" ? StandardPaths.writableLocation(StandardPaths.HomeLocation) : path
    property real spacing: 4

    id: workspaceCard
    height: cardHeader.height + (expanded ? folderColumnView.height + spacing : 0)
    color: "#001E36"
    radius: 15

    onExpandedChanged: {
        if (folderColumnView.model === 0)
            folderColumnView.loadModel()
    }

    Item {
        id: cardHeader
        width: parent.width
        height: Math.max(workspaceForeground.height / 14, 50)

        MouseArea {
            anchors.fill: parent
            onPressed: workspaceForeground.actualPath = realPath
        }

        DefaultFoldButton {
            id: workspaceFoldButton
            width: parent.width * 0.08
            height: parent.height * 0.3
            x: parent.x + width / 3
            y: parent.height / 2 - height / 2
        }

        TextField {
            id: workspaceName
            width: parent.width - workspaceFoldButton.width - workspaceFoldButton.x - editModeButton.width * 2
            x: workspaceFoldButton.width + workspaceFoldButton.x
            y: parent.height / 2 - height / 2
            color: "#FFFFFF"
            opacity: enabled ? 0.6 : 0.4
            enabled: editModeEnabled
            text: name + " " + realPath

            background: Rectangle {
                anchors.fill: parent
                color: "transparent"
            }
        }

        DefaultImageButton {
            id: editModeButton
            width: parent.width * 0.08
            height: parent.height * 0.4
            x: parent.width * 0.85
            y: parent.height / 2 - height / 2
            //source: "qrc:/Assets/EditWorkspaceName.png"

            onClicked: editModeEnabled = !editModeEnabled
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
