import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

WorkspaceBackground {
    id: workspaceView

    WorkspaceViewTitle {
        id: workspaceViewTitle
        x: (workspaceForeground.width + (parent.width - workspaceForeground.width) / 2) - width / 2
        y: height
    }

    WorkspaceForeground {
        id: workspaceForeground
        x: parent.parent.x
        y: parent.parent.y
        width: Math.max(parent.width * 0.2, 350)
        height: parent.height
    }

    //WorkspaceContentArea {
    //    id: workspaceContentArea
    //    anchors.top: workspaceViewTitle.bottom
    //    anchors.left: workspaceForeground.right
    //    anchors.right: workspaceView.right
    //    anchors.bottom: workspaceView.bottom
    //    anchors.margins: parent.width * 0.05
    //}
}
