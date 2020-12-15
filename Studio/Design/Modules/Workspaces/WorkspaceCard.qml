import QtQuick 2.15
import QtQuick.Controls 2.15

import '../../Default'

Rectangle {
    property bool editModeEnabled: false
    id: workspaceCard
    width: parent.width
    height: parent.height
    color: "#001E36"
    radius: 15

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
        text: "WORKSPACE PAR DEFAULT"
        color: "#FFFFFF"
        opacity: enabled ? 0.6 : 0.4
        enabled: false

        TextMetrics {
            elide: Text.ElideRight
        }

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
        //source: "qrc:/editWorkspaceName.png"

        onClicked:  {
            editModeEnabled ? editModeEnabled = false : editModeEnabled = true
            editModeEnabled ? workspaceName.enabled = true : workspaceName.enabled = false
        }
    }
}
