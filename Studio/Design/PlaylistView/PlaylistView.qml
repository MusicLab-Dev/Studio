import QtQuick 2.15
import QtQuick.Layouts 1.15
import "qrc:/PlaylistView/PlaylistViewContent"


Rectangle {
    id: playlistView

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PlaylistViewHeader {
            Layout.preferredHeight: parent.height * 0.125
            Layout.preferredWidth: parent.width
            z: 1
        }

        PlaylistViewContent {
            Layout.preferredHeight: parent.height * 0.75
            Layout.preferredWidth: parent.width
        }

        PlaylistViewFooter {
            Layout.preferredHeight: parent.height * 0.125
            Layout.preferredWidth: parent.width
        }
    }
}
