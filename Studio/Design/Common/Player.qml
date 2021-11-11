import QtQuick 2.15
import QtQuick.Layouts 1.15

PlayerRef {
    // Inputs
    property alias targetPlaybackMode: base.targetPlaybackMode
    property alias isPartitionPlayer: base.isPartitionPlayer
    property alias targetNode: base.targetNode
    property alias targetPartitionIndex: base.targetPartitionIndex

    // Loop inputs
    property alias hasLoop: base.hasLoop
    property alias playFrom: base.playFrom
    property alias loopFrom: base.loopFrom
    property alias loopTo: base.loopTo
    property alias loopRange: base.loopRange

    // Cache
    property alias currentPlaybackBeat: base.currentPlaybackBeat
    property alias isPlayerRunning: base.isPlayerRunning

    playerBase: base

    PlayerBase {
        id: base
    }
}
