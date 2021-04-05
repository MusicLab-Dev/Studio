import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Common"

ContentView {
    id: contentView
    xOffsetMin: -5000
    yOffsetMin: pianoView.totalHeight > height ? height - pianoView.totalHeight : 0
    rowHeaderWidth: pianoView.keyWidth
    clip: true
    placementKeyCount: pianoView.keys
    placementKeyOffset: pianoView.keyOffset

    SequencerContentPianoView {
        id: pianoView
        y: contentView.yOffset
        width: parent.width
        height: parent.height
    }
}
