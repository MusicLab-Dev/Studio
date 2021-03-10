import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/PlaylistView/PlaylistViewContent"


Rectangle {
    id: playlistView

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PlaylistViewHeader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height * 0.1
            z: 1
        }

        PlaylistViewContent {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: parent.height * 0.8
            Layout.preferredWidth: parent.width
        }

        PlaylistViewFooter {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: parent.height * 0.1
            Layout.preferredWidth: parent.width
        }
    }
}
