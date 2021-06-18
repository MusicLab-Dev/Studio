import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

Item {
    property bool expanded: foldButton.activated
    property real spacing: 4
    property int depth: 0

    id: folderColumnFolderDelegate
    height: folderRow.height + (expanded ? folderColumnView.height + spacing : 0)

    onExpandedChanged: {
        if (folderColumnView.model === 0)
            folderColumnView.loadModel()
    }

    Row {
        id: folderRow
        width: parent.width
        height: 20
        spacing: 4

        DefaultFoldButton {
            id: foldButton
            width: parent.height / 1.5
            height: width
            y: parent.height / 2 - height / 2
        }

        DefaultTextButton {
            width: parent.width - foldButton.width - parent.spacing
            text: fileName
            height: parent.height

            onReleased: {
                if (fileIsDir) {
                    workspaceForeground.actualPath = fileUrl
                    workspaceView.lastSelectedWorkspace = workspaceCard.workspaceName.text
                    workspaceForeground.parentDepth = depth
                }
            }
        }
    }

    FolderColumnView {
        id: folderColumnView
        visible: folderColumnFolderDelegate.expanded
        width: parent.width
        anchors.top: folderRow.bottom
        anchors.topMargin: folderColumnFolderDelegate.spacing
        realPath: fileUrl
        depth: folderColumnFolderDelegate.depth
    }
}
