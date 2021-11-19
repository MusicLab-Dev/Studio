import QtQuick 2.0
import QtQuick.Layouts 1.3

import "."

RowLayout {
    property alias player: player

    id: playerArea

    TimerView {
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width * 0.3
        currentPlaybackBeat: player.playerBase.currentPlaybackBeat
    }

    Bpm {
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width * 0.3
    }

    PlayerRef {
        id: player
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
