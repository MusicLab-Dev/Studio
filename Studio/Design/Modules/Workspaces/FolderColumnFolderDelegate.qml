import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Item {
    property bool expanded: foldButton.activated
    property real spacing: 4

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
            width: 20
            height: 20
        }

        DefaultTextButton {
            text: fileName
            height: parent.height

            onReleased: {
                if (fileIsDir)
                    workspaceForeground.actualPath = fileUrl
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
    }
}

// Item {
//     property bool expanded: folderFoldButton.activated

//     id: workspaceCard
//     height: cardHeader.height + (expanded ? folderColumnView.height + spacing : 0)


//     Item {
//         id: cardHeader
//         width: parent.width
//         height: Math.max(workspaceForeground.height / 14, 50)

//         MouseArea {
//             anchors.fill: parent
//             onPressed: workspaceForeground.actualPath = realPath
//         }

//         DefaultFoldButton {
//             id: folderFoldButton
//             width: parent.width * 0.08
//             height: parent.height * 0.3
//             x: parent.x + width / 3
//             y: parent.height / 2 - height / 2
//         }

//         TextField {
//             id: workspaceName
//             width: parent.width - workspaceFoldButton.width - workspaceFoldButton.x - editModeButton.width * 2
//             x: workspaceFoldButton.width + workspaceFoldButton.x
//             y: parent.height / 2 - height / 2
//             color: "#FFFFFF"
//             opacity: enabled ? 0.6 : 0.4
//             enabled: editModeEnabled
//             text: name + " " + realPath

//             background: Rectangle {
//                 anchors.fill: parent
//                 color: "transparent"
//             }
//         }

//         DefaultImageButton {
//             id: editModeButton
//             width: parent.width * 0.08
//             height: parent.height * 0.4
//             x: parent.width * 0.85
//             y: parent.height / 2 - height / 2
//             //source: "qrc:/Assets/EditWorkspaceName.png"

//             onClicked: editModeEnabled = !editModeEnabled
//         }
//     }

//     FolderColumnView {
//         id: folderColumnView
//         visible: workspaceCard.expanded
//         width: parent.width
//         anchors.top: cardHeader.bottom
//         anchors.topMargin: workspaceCard.spacing
//     }
// }



