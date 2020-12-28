import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15
import QtQuick.Dialogs 1.3

Rectangle {
    id: workspaceBackground
    color: "#001E36"

    GridView {
        anchors.fill: parent
        cellWidth: Math.max(parent.width / 5, 250)
        cellHeight: Math.max(parent.width / 5, 250)

        model: FolderListModel {
            id: folderModel
            folder: workspaceForeground.actualPath
        }

        delegate: WorkspacesSquareComponent {
            Image {
                id: image
                anchors.fill: parent
                source: fileIsDir ? "qrc:/Assets/TestImage3.png" : "qrc:/Assets/TestImage4.png"
            }

            WorkspacesSquareComponentTitle {
                width: image.width * 1.4
                text: fileName
                color: "white"
            }

            MouseArea {
                anchors.fill: parent

                onDoubleClicked: {
                    if (fileIsDir)
                        workspaceForeground.actualPath = fileUrl
                }
            }
        }
    }
}
