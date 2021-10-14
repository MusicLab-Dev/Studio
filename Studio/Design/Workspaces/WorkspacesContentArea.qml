import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import QtQuick.Dialogs 1.3

import '../Default'

Item {
    property int selectedIndex: -1
    property string selectedPath: ""
    property bool selectedIndexIsDir: true

    id: workspaceBackground

    GridView {
        anchors.fill: parent
        cellWidth: Math.max(parent.width / 5, 250)
        cellHeight: Math.max(parent.width / 5, 250)
        clip: true

        ScrollBar.vertical: DefaultScrollBar {
            id: scrollBar
            color: themeManager.accentColor
            opacity: 0.3
            visible: parent.contentHeight > parent.height
        }

        model: FolderListModel {
            id: folderModel
            folder: workspaceForeground.actualPath
            nameFilters: ["*" + workspaceView.searchFilter + "*.wav"]
            caseSensitive: false
            showDirsFirst: true
        }

        delegate: Rectangle {
            id: workspacesSquareComponent
            width: 161
            height: 161
            radius: 6
            color: "transparent"
            border.width: 2
            border.color: workspaceBackground.selectedIndex === index ? themeManager.accentColor : image.hovered ? themeManager.semiAccentColor : "transparent"

            DefaultImageButton {
                id: image
                anchors.fill: parent
                anchors.margins: 5
                source: fileIsDir ? "qrc:/Assets/TestImage3.png" : "qrc:/Assets/TestImage4.png"
                colorDefault: workspaceBackground.selectedIndex === index ? themeManager.accentColor : "white"

                onDoubleClicked: {
                    if (fileIsDir) {
                        workspaceForeground.actualPath = fileUrl
                        workspaceForeground.parentDepth += 1
                        workspacesViewBackButtonText.visible = true
                    } else {
                        workspaceView.fileUrl = fileUrl
                        workspaceView.acceptAndClose()
                    }
                }

                onClicked: {
                    selectedIndex = index
                    selectedPath = fileUrl
                    selectedIndexIsDir = fileIsDir
                }

                onPressed: { selectedIndex = index }
            }

            WorkspacesSquareComponentTitle {
                width: image.width * 1.4
                text: fileName
                color: workspaceBackground.selectedIndex === index ? themeManager.accentColor : image.hovered ? themeManager.semiAccentColor : "white"
            }
        }
    }
}
