import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../../Default"


Rectangle {
    property var workspacesModel
    property string actualPath: ""
    property int parentDepth: 0
    property alias searchFilter: searchBar.text

    onActualPathChanged: {
        workspaceContentArea.selectedIndex = -1
        workspaceContentArea.hoveredIndex = -1
    }

    id: workspaceForeground
    color: "#0D2D47"
    radius: 30

    Rectangle {
        width: parent.width * 0.1
        height: parent.height
        anchors.right: parent.right
        color: parent.color
    }

    Item {
        id: workspaceResearchTextInput
        width: parent.width * 0.8
        height : parent.height * 0.05
        x: (parent.width - width) / 2
        y: (parent.height - height) / 10

        DefaultTextInput {
            id: searchBar
            anchors.fill: parent
            placeholderText: qsTr("Default files")
            color: "white"
            opacity: 0.42
        }
    }

    ScrollView {
        id: workspacesForegroundScrollView
        width: parent.width * 0.8
        height: parent.height * 0.75
        x: (parent.width - width) / 2
        y: workspaceResearchTextInput.y + workspaceResearchTextInput.height * 2
        clip: true

        Column {
            id: workspaceForegroundContent
            width: parent.width
            spacing: Math.max(workspaceForeground.height / 30, 20)

            Repeater {
                model: workspacesModel

                delegate: WorkspaceCard {
                    width: workspacesForegroundScrollView.width - 15

                    Component.onCompleted: {
                        if (index === 0) {
                            workspaceForeground.actualPath = realPath
                        }
                    }
                }
            }
        }
    }

    DefaultTextButton {
        text: qsTr("+ NEW WORKSPACE")

        anchors.top: workspacesForegroundScrollView.bottom
        anchors.horizontalCenter: workspacesForegroundScrollView.horizontalCenter

        onClicked: folderPicker.open()
    }
}
