import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15

Rectangle {
    id: workspaceBackground
    color: "#001E36"

    GridView {
        anchors.fill: parent
        cellWidth: 250
        cellHeight: 250

        FolderListModel {
            id: folderModel
            rootFolder: workspaceForeground.actualPath
            nameFilters: ["*.*"]
        }

        model: folderModel
        delegate: WorkspacesSquareComponent {

            Image {
                anchors.fill: parent
                source: fileIsDir ? "qrc:/Assets/TestImage3.png" : "qrc:/Assets/TestImage4.png"
            }

            WorkspacesSquareComponentTitle {
                text: fileName
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onPressed: {
                    workspaceForeground.actualPath = filePath
                    folderModel.rootFolder = filePath
                    console.log(workspaceForeground.actualPath)
                }
            }
        }
    }
}
