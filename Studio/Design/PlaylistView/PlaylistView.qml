import QtQuick 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    property int moduleIndex: -1
    property alias player: playlistViewFooter.player

    id: playlistView
    spacing: 0

    function onNodeDeleted(targetNode) {}

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) {}

    PlaylistViewHeader {
        id: playlistViewHeader
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height * 0.1
        z: 1
    }

    PlaylistViewContent {
        id: playlistViewContent
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.8
        Layout.preferredWidth: parent.width
    }

    PlaylistViewFooter {
        id: playlistViewFooter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.1
        Layout.preferredWidth: parent.width
    }
}
