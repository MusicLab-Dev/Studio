import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0

import "../../Common"

ContentView {
    property alias pianoView: pianoView

    id: contentView
    xOffsetMin: sequencerView.partition ? Math.max(sequencerView.partition.latestNote, placementBeatPrecisionTo) * -pixelsPerBeatPrecision : 0
    yOffsetMin: pianoView.totalHeight > surfaceContentGrid.height ? surfaceContentGrid.height - pianoView.totalHeight : 0
    yZoom: 0.05
    yZoomMin: 15
    yZoomMax: 120
    rowHeaderWidth: pianoView.keyWidth
    clip: true
    placementKeyCount: pianoView.keys
    placementKeyOffset: pianoView.keyOffset
    timelineBeatPrecision: sequencerView.player.currentPlaybackBeat
    audioProcessBeatPrecision: app.scheduler.partitionCurrentBeat
    placementBeatPrecisionScale: AudioAPI.beatPrecision / 4

    SequencerContentPianoView {
        id: pianoView
        y: contentView.yOffset
        width: contentView.width
    }
}
