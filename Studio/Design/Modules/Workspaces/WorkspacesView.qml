import QtQuick 2.15
import QtQuick.Controls 2.15

WorkspacesBackground {
    id: workspacesView

    WorkspacesViewTitle {
        id: workspacesViewTitle
        x: (workspacesForeground.width + (parent.width - workspacesForeground.width) / 2) - width / 2
        y: height
    }

    WorkspacesForeground {
        id: workspacesForeground
        x: parent.parent.x
        y: parent.parent.y
        width: Math.max(parent.width * 0.2, 350)
        height: parent.height
    }

    //WorkspacesContentArea {
    //    id: workspacesContentArea
    //    anchors.top: workspacesViewTitle.bottom
    //    anchors.left: workspacesForeground.right
    //    anchors.right: workspacesView.right
    //    anchors.bottom: workspacesView.bottom
    //    anchors.margins: parent.width * 0.05
    //}
}
