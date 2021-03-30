import QtQuick 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: playlistView
    spacing: 0

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
