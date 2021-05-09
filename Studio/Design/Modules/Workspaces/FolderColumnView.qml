import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.folderlistmodel 2.15

Column {
    property int depth: 0
    property alias model: repeater.model
    property string realPath
    readonly property real indentationSize: 20

    function loadModel() {
        repeater.model = Qt.createQmlObject(
        "import Qt.labs.folderlistmodel 2.15
        FolderListModel {
            id: folderModel
            folder: realPath
            nameFilters: [\"*\" + workspaceView.searchFilter + \"*.wav\"]
            caseSensitive: false
            showDirsFirst: true
        }", repeater, "FolderModel")
    }

    id: folderColumnView

    Repeater {
        id: repeater

        model: 0

        delegate: Loader {
            x: indentationSize
            source: "qrc:/Modules/Workspaces/" + (fileIsDir ? "FolderColumnFolderDelegate.qml" : "FolderColumnFileDelegate.qml")
            width: folderColumnView.width - x

            onLoaded: item.depth = depth + 1
        }
    }
}
