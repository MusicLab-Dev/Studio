import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Rectangle {
    id: workspacesForeground
    color: "#0D2D47"
    radius: 30

    Rectangle {
        width: parent.width * 0.1
        height: parent.height
        anchors.right: parent.right
        color: parent.color
    }

    Item {
        id: workspacesResearchTextInput
        width: parent.width * 0.8
        height : parent.height * 0.05
        x: (parent.width - width) / 2
        y: (parent.height - height) / 10

        DefaultTextInput {
            anchors.fill: parent
            color: "white"
            opacity: 0.42
        }
    }


    Item {
        id: workspacesForegroundContent
        width: parent.width * 0.8
        height: parent.height * 0.7
        x: (parent.width - width) / 2
        y: workspacesResearchTextInput.y + workspacesResearchTextInput.height * 2

        //ListView {
        //    anchors.fill: parent
        //    spacing: parent.height * 0.04
        //
        //    }
        //}

    }
}
