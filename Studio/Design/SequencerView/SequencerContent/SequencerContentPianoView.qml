import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../Common"

import AudioAPI 1.0

Item {
    readonly property var keyNames: [
        qsTr("C"), qsTr("C#"), qsTr("D"), qsTr("D#"), qsTr("E"), qsTr("F"),
        qsTr("F#"), qsTr("G"), qsTr("G#"), qsTr("A"), qsTr("A#"), qsTr("B"),
    ]
    readonly property var hashKeyStates: [
        false, true, false, true, false, false,
        true, false, true, false, true, false
    ]
    readonly property var middleHashKeysStates: [
        false, false, true, false, false, false,
        false, true, false, true, false, false
    ]
    readonly property var upHashKeyStates: [
        true, false, true, false, false, true,
        false, true, false, true, false, false
    ]
    readonly property var downHashKeyStates: [
        false, false, true, false, true, false,
        false, true, false, true, false, true
    ]
    readonly property int keysPerOctave: keyNames.length
    property int octaves: 8
    property int octaveOffset: 2
    readonly property int keyOffset: octaveOffset * keysPerOctave
    readonly property int keys: keysPerOctave * octaves
    property real headerFactor: 0.1
    property real keyWidth: parent.width * headerFactor
    readonly property real totalHeight: keys * rowHeight
    readonly property real snapperHeight: 30

    id: pianoView
    height: totalHeight


    Connections {
        target: eventDispatcher

        property real octave: 5

        function launch(pressed, key) {
            sequencerView.node.partitions.addOnTheFly(
                AudioAPI.noteEvent(
                    !pressed,
                    (octave * 12) + key,
                    AudioAPI.velocityMax,
                    0
                    ),
                sequencerView.node,
                sequencerView.partitionIndex
            )
        }

        function onNote0(pressed) { launch(pressed, 0) }
        function onNote1(pressed) { launch(pressed, 1) }
        function onNote2(pressed) { launch(pressed, 2) }
        function onNote3(pressed) { launch(pressed, 3) }
        function onNote4(pressed) { launch(pressed, 4) }
        function onNote5(pressed) { launch(pressed, 5) }
        function onNote6(pressed) { launch(pressed, 6) }
        function onNote7(pressed) { launch(pressed, 7) }
        function onNote8(pressed) { launch(pressed, 8) }
        function onNote9(pressed) { launch(pressed, 9) }
        function onNote10(pressed) { launch(pressed, 10) }
        function onNote11(pressed) { launch(pressed, 11) }
        function onOctaveUp(pressed) { if (pressed) octave++ }
        function onOctaveDown(pressed) { if (pressed) octave-- }
    }


    Repeater {
        model: pianoView.keys

        delegate: Item {
            readonly property int keyIndex: pianoView.keyOffset + (pianoView.keys - 1 - index)
            readonly property int keyOctaveIndex: keyIndex % keysPerOctave
            readonly property int currentOctave: keyIndex / keysPerOctave
            readonly property bool isHashKey: hashKeyStates[keyOctaveIndex]
            readonly property bool isInMiddleOfHashKeys: middleHashKeysStates[keyOctaveIndex]
            readonly property bool isUpHashKey: upHashKeyStates[keyOctaveIndex]
            readonly property bool isDownHashKey: downHashKeyStates[keyOctaveIndex]
            readonly property color keyColor: keyOctaveIndex === 0 ? "#C2C2C2" : isHashKey ? "#7B7B7B" : "#E7E7E7"
            readonly property int placementOffset: keyOctaveIndex == 11 ? 0 : 1

            id: key
            width: pianoView.keyWidth
            height: contentView.rowHeight
            y: index * contentView.rowHeight
            z: isHashKey ? 100 : 1

            Rectangle {
                id: keyBackground
                y: (key.isUpHashKey ? -contentView.rowHeight / 2 : 0) - placementOffset
                z: 1
                width: (key.isHashKey ? pianoView.keyWidth * 0.75 : pianoView.keyWidth) - x
                height: contentView.rowHeight * (key.isHashKey ? 1 : key.isInMiddleOfHashKeys ? 2 : 1.5) + placementOffset
                color: keyMouseArea.pressed ? Qt.darker(key.keyColor, 1.2) : key.keyColor
                border.color: key.isHashKey ? color : "#7B7B7B"
                border.width: 1

                MouseArea {
                    id: keyMouseArea
                    anchors.fill: parent

                    onPressedChanged: {
                        sequencerView.node.partitions.addOnTheFly(
                                    AudioAPI.noteEvent(
                                        pressed ? NoteEvent.On : NoteEvent.Off,
                                        key.keyIndex,
                                        AudioAPI.velocityMax,
                                        0
                                        ),
                                    sequencerView.node,
                                    sequencerView.partitionIndex
                                    )
                    }
                }

                Text {
                    anchors.verticalCenter: key.isInMiddleOfHashKeys ? parent.verticalCenter : key.isDownHashKey ? parent.TopRight : parent.verticalCenter
                    anchors.right: parent.right
                    text: pianoView.keyNames[key.keyOctaveIndex] + (key.currentOctave - 1) // Minus one to display the standard A4 middle key
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
        brushStep: contentView.placementBeatPrecisionBrushStep

        Repeater {
            model: sequencerView.partition

            delegate: Rectangle {
                readonly property var beatRange: range

                y: (pianoView.keys - 1 - (key - pianoView.keyOffset)) * contentView.rowHeight
                x: contentView.xOffset + beatRange.from * contentView.pixelsPerBeatPrecision
                width: (beatRange.to - beatRange.from) * contentView.pixelsPerBeatPrecision
                height: contentView.rowHeight
                color: themeManager.getColorFromChain(key)
                border.color: Qt.darker(color, 1.25)
                border.width: 2

                Rectangle {
                    x: Math.min(parent.width * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                    y: parent.height / 8
                    width: 1
                    height: contentView.rowHeight * 3 / 4
                    color: parent.border.color
                }

                Rectangle {
                    x: parent.width - Math.min(parent.width * contentView.placementResizeRatioThreshold, contentView.placementResizeMaxPixelThreshold)
                    y: parent.height / 8
                    width: 1
                    height: contentView.rowHeight * 3 / 4
                    color: parent.border.color
                }
            }
        }
    }
}
