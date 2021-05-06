import QtQuick 2.15
import QtQuick.Layouts 1.15

import "./PlaylistContent"

ColumnLayout {
    enum EditMode {
        Regular,
        Brush,
        Select,
        Cut
    }

    property string moduleName: "Playlist"
    property int moduleIndex: -1
    property alias player: playlistViewFooter.player
    property int editMode: PlaylistView.EditMode.Regular

    function onNodeDeleted(targetNode) { return false; }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) { return false }

    id: playlistView
    spacing: 0
    focus: true

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === componentSelected

        function onPlayContext(pressed) { if (!pressed) return; player.playOrPause() }
        function onPauseContext(pressed) { if (!pressed) return; player.pause(); }
        function onStopContext(pressed) { if (!pressed) return; player.stop(); }
    }

    Connections {
        target: eventDispatcher

        function onPlayPlaylist(pressed) { if (!pressed) return; player.playOrPause() }
        function onPausePlaylist(pressed) { if (!pressed) return; player.pause(); }
        function onStopContext(pressed) { if (!pressed) return; player.stop(); }
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
