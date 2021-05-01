import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Common"

ContentView {
    property alias pianoView: pianoView

    id: contentView
    xOffsetMin: sequencerView.partition ? sequencerView.partition.latestNote * -pixelsPerBeatPrecision : 0
    yOffsetMin: pianoView.totalHeight > surfaceContentGrid.height ? surfaceContentGrid.height - pianoView.totalHeight : 0
    rowHeaderWidth: pianoView.keyWidth
    clip: true
    placementKeyCount: pianoView.keys
    placementKeyOffset: pianoView.keyOffset
    timelineBeatPrecision: sequencerView.player.currentPlaybackBeat
    audioProcessBeatPrecision: app.scheduler.partitionCurrentBeat

    SequencerContentPianoView {
        id: pianoView
        y: contentView.yOffset
        width: contentView.width
    }
}
