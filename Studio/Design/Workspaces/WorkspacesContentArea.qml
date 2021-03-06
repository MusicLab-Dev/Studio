import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import QtQuick.Dialogs 1.3

import '../Default'

Rectangle {
    property int selectedIndex: -1
    property string selectedPath: ""
    property bool selectedIndexIsDir: true
    property int hoveredIndex: -1

    id: workspaceBackground
    color: "#001E36"

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

        delegate: WorkspacesSquareComponent {
            id: workspacesSquareComponent

            border.width: 2
            border.color: selectedIndex === index ? themeManager.accentColor : hoveredIndex === index ? "#1E6FB0" : "transparent"

            Image {
                id: image
                anchors.fill: parent
                anchors.margins: 5
                source: fileIsDir ? "qrc:/Assets/TestImage3.png" : "qrc:/Assets/TestImage4.png"
            }

            WorkspacesSquareComponentTitle {
                width: image.width * 1.4
                text: fileName
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onDoubleClicked: {
                    if (fileIsDir) {
                        workspaceForeground.actualPath = fileUrl
                        workspaceForeground.parentDepth += 1
                    } else {
                        workspaceView.fileUrl = fileUrl
                        workspaceView.acceptAndClose()
                    }
                    workspacesViewBackButtonText.visible = true
                }

                onClicked: {
                    selectedIndex = index
                    selectedPath = fileUrl
                    selectedIndexIsDir = fileIsDir
                }

                onEntered: { hoveredIndex = index }

                onPressed: { selectedIndex = index }

                onExited: { hoveredIndex = -1 }
            }
        }
    }
}
