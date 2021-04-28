import QtQuick 2.15
import QtQuick.Layouts 1.15

import "./PlaylistContent"

ColumnLayout {
    property int moduleIndex: -1
    property alias player: playlistViewFooter.player

    function onNodeDeleted(targetNode) { return false; }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) { return false }

    id: playlistView
    spacing: 0
    focus: true

    Keys.onPressed: {
        if (event.key == Qt.Key_A)
            player.stop()
        else if (event.key == Qt.Key_Z)
            player.replay()
        else if (event.key == Qt.Key_E)
            player.playOrPause()
    }

    PlaylistViewHeader {
        id: playlistViewHeader
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height * 0.1
        z: 1
    }

    PlaylistContentView {
        id: contentView
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.8
        Layout.preferredWidth: parent.width

        onTimelineBeginMove: playlistViewFooter.player.timelineBeginMove(target)
        onTimelineMove: playlistViewFooter.player.timelineMove(target)
        onTimelineEndMove: playlistViewFooter.player.timelineEndMove()
    }

    PlaylistViewFooter {
        id: playlistViewFooter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.1
        Layout.preferredWidth: parent.width
    }
}
