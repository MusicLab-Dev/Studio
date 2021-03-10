import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../../Default/"
import "../../Common"

Rectangle {
    property real headerFactor: 0.1

    color: "#001E36"

    Column {
        id: contentColumn
        width: parent.width
        height: parent.height
        spacing: 0

        // Add timeline here later

        PlaylistViewContentFlickable {
            id: playlistViewContentFlickable
            width: parent.width
            height: parent.height // * 0.97
        }
    }
}


