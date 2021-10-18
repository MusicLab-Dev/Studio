import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0

import "../Common"

ContentView {
    function centerTargetOctave() {
        var centerKey = (pianoView.keys - (pianoView.targetOctave - pianoView.octaveOffset) * pianoView.keysPerOctave) - pianoView.keysPerOctave / 2
        var dt = -centerKey * rowHeight + height / 2 - rowHeight / 2
        yOffset = Math.min(Math.max(dt, yOffsetMin), 0)
    }

    property alias pianoView: pianoView
    property alias placementArea: pianoView.placementArea

    id: contentView
    playerBase: sequencerView.player.playerBase
    xOffsetMin: sequencerView.partition ? Math.max(sequencerView.partition.latestNote, placementBeatPrecisionTo) * -pixelsPerBeatPrecision : 0
    yOffsetMin: pianoView.totalHeight > surfaceContentGrid.height ? surfaceContentGrid.height - pianoView.totalHeight : 0
    xZoom: 0.025
    yZoom: 0.05
    yZoomMin: 15
    yZoomMax: 120
    rowHeaderWidth: pianoView.keyWidth
    clip: true
    placementKeyCount: pianoView.keys
    placementKeyOffset: pianoView.keyOffset
    placementBeatPrecisionScale: AudioAPI.beatPrecision / 4
    contentViewTimeline.upTimeline.color: sequencerView.node ? sequencerView.node.color : "black"

    SequencerContentPianoView {
        id: pianoView
        y: contentView.yOffset
        width: contentView.width
    }
}
