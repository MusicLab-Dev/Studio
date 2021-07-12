import QtQuick 2.15
import QtQuick.Layouts 1.15

import ActionsManager 1.0

ColumnLayout {
    enum EditMode {
        Regular,
        Brush,
        Select,
        Cut
    }

    property string moduleName: "Playlist"
    property int moduleIndex
    property alias player: playlistViewFooter.player
    property int editMode: PlaylistView.EditMode.Regular

    function onNodeDeleted(targetNode) { return false; }

    function onNodePartitionDeleted(targetNode, targetPartitionIndex) { return false }

    id: playlistView
    spacing: 0
    focus: true

    Connections {
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

        function onPlayContext(pressed) { if (!pressed) return; player.playOrPause() }
        function onReplayContext(pressed) { if (!pressed) return; player.replay(); }
        function onStopContext(pressed) { if (!pressed) return; player.stop(); }
    }

    Connections {
        target: eventDispatcher

        function onPlayPlaylist(pressed) { if (!pressed) return; player.playOrPause() }
        function onReplayPlaylist(pressed) { if (!pressed) return; player.replay(); }
        function onStopPlaylist(pressed) { if (!pressed) return; player.stop(); }
    }

    PlaylistHeader {
        id: playlistViewHeader
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: parent.height * 0.15
        z: 1
    }

    PlaylistContentView {
        id: contentView
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.7
        Layout.preferredWidth: parent.width
        clip: true

        onTimelineBeginMove: playlistViewFooter.player.timelineBeginMove(target)
        onTimelineMove: playlistViewFooter.player.timelineMove(target)
        onTimelineEndMove: playlistViewFooter.player.timelineEndMove()
        onTimelineBeginLoopMove: playlistViewFooter.player.timelineBeginLoopMove()
        onTimelineEndLoopMove: playlistViewFooter.player.timelineEndLoopMove()
    }

    PlaylistFooter {
        id: playlistViewFooter
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: parent.height * 0.15
        Layout.preferredWidth: parent.width
    }

    ActionsManager {
        id: actionsManager
    }

}
