import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    readonly property var keyNames: [
        qsTr("C"), qsTr("C#"), qsTr("D"), qsTr("D#"), qsTr("E"), qsTr("F"),
        qsTr("F#"), qsTr("G"), qsTr("G#"), qsTr("A"), qsTr("A#"), qsTr("B"),
    ]
    readonly property var hashKeyStates: [
        false, true, false, true, false, true,
        false, false, true, false, true, false
    ]
    readonly property var middleHashKeysStates: [
        false, false, true, false, true, false,
        false, false, false, true, false, false
    ]
    readonly property var upHashKeyStates: [
        false, false, true, false, true, false,
        true, false, false, true, false, true
    ]
    readonly property var downHashKeyStates: [
        true, false, true, false, true, false,
        false, true, false, true, false, false
    ]
    readonly property int keysPerOctave: keyNames.length
    property int octaves: 6
    property int octaveOffset: 2
    readonly property int keyOffset: octaveOffset * keysPerOctave
    readonly property int keys: keysPerOctave * octaves
    property real headerFactor: 0.1
    property real keyWidth: parent.width * headerFactor
    readonly property real totalHeight: keys * rowHeight

    id: pianoView
    width: contentView.width
    height: totalHeight

    Repeater {
        model: pianoView.keys

        delegate: Item {
            readonly property int currentOctave: octaveOffset + (pianoView.keys - index) / keysPerOctave
            readonly property int keyIndex: index % keysPerOctave
            readonly property bool isHashKey: hashKeyStates[keyIndex]
            readonly property bool isInMiddleOfHashKeys: middleHashKeysStates[keyIndex]
            readonly property bool isUpHashKey: upHashKeyStates[keyIndex]
            readonly property bool isDownHashKey: downHashKeyStates[keyIndex]
            readonly property color keyColor: isHashKey ? "#7B7B7B" : "#E7E7E7"

            id: key
            width: pianoView.keyWidth
            height: contentView.rowHeight
            y: index * contentView.rowHeight
            z: isHashKey ? 100 : 1

            Rectangle {
                id: keyBackground
                y: key.isUpHashKey ? -contentView.rowHeight / 2 : 0
                z: 1
                width: (key.isHashKey ? pianoView.keyWidth * 0.75 : pianoView.keyWidth) - x
                height: contentView.rowHeight * (key.isHashKey ? 1 : key.isInMiddleOfHashKeys ? 2 : 1.5)
                color: key.keyColor
                border.color: key.isHashKey ? color : "#7B7B7B"
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        keyBackground.color = Qt.darker(keyBackground.color, 1.2)
                    }
                    onReleased: {
                        keyBackground.color = keyColor
                    }
                }

                Text {
                    anchors.verticalCenter: key.isInMiddleOfHashKeys ? parent.verticalCenter : key.isDownHashKey ? parent.TopRight : parent.verticalCenter
                    anchors.right: parent.right
                    text: pianoView.keyNames[key.keyIndex] + (key.currentOctave - 1)
                    color: !key.isHashKey ? "#7B7B7B" : "#E7E7E7"
                    z: 1
                }
            }
        }
    }

    NotesPlacementArea {
        x: contentView.rowHeaderWidth
        width: contentView.rowDataWidth
        height: pianoView.totalHeight
        partition: sequencerView.partition

        Repeater {
            model: sequencerView.partition

            delegate: Rectangle {
                readonly property var beatRange: range

                y: (pianoView.keys - 1 - (key - pianoView.keyOffset)) * contentView.rowHeight
                x: contentView.xOffset + beatRange.from * contentView.pixelsPerBeatPrecision
                width: (beatRange.to - beatRange.from) * contentView.pixelsPerBeatPrecision
                height: contentView.rowHeight
                color: themeManager.getColorFromChain(key)
            }
        }
    }
}
