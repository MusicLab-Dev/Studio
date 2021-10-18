import QtQuick 2.15
import QtQuick.Controls 2.15
import "../Common"
import "../Default"

import AudioAPI 1.0

Item {
    property alias placementArea: placementArea

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
    readonly property int octaveMin: octaveOffset
    readonly property int octaveMax: octaves + octaveOffset
    readonly property int keyMin: octaveMin * keysPerOctave
    readonly property int keyMax: octaveMax * keysPerOctave - 1
    readonly property int keyOffset: octaveOffset * keysPerOctave
    readonly property int keys: keysPerOctave * octaves
    property real headerFactor: 0.07
    property real keyWidth: parent.width * headerFactor
    readonly property real totalHeight: keys * rowHeight
    readonly property real snapperHeight: 30

    // Target octave
    property real targetOctave: 5

    id: pianoView
    height: totalHeight

    Connections {
        function launch(pressed, key) {
            if (sequencerView.node)
                sequencerView.node.partitions.addOnTheFly(
                    AudioAPI.noteEvent(!pressed, (pianoView.targetOctave * keysPerOctave) + key, AudioAPI.velocityMax, 0),
                    sequencerView.node,
                    sequencerView.partitionIndex,
                    true
                )
        }

        function octaveUp() {
            pianoView.targetOctave = Math.min(pianoView.targetOctave + 1, octaveMax - 1)
            contentView.centerTargetOctave()
        }

        function octaveDown() {
            pianoView.targetOctave = Math.max(pianoView.targetOctave - 1, octaveMin)
            contentView.centerTargetOctave()
        }

        id: notesConnections
        target: eventDispatcher
        enabled: moduleIndex === modulesView.selectedModule

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
        function onOctaveUp(pressed) { if (pressed) octaveUp() }
        function onOctaveDown(pressed) { if (pressed) octaveDown() }
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
            readonly property color keyColor: keyOctaveIndex === 0 ? "#C2C2C2" : isHashKey ? themeManager.backgroundColor : "white"
            readonly property int placementOffset: keyOctaveIndex == 11 ? 0 : 1

            id: key
            width: pianoView.keyWidth
            height: contentView.rowHeight
            y: index * contentView.rowHeight
            z: isHashKey ? 2 : 1

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
                        forceActiveFocus()
                        sequencerView.node.partitions.addOnTheFly(
                            AudioAPI.noteEvent(
                                pressed ? NoteEvent.On : NoteEvent.Off,
                                key.keyIndex,
                                AudioAPI.velocityMax,
                                0
                            ),
                            sequencerView.node,
                            sequencerView.partitionIndex,
                            true
                        )
                    }
                }

                Text {
                    visible: keyIndex % 12 == 0
                    anchors.verticalCenter: key.isInMiddleOfHashKeys ? parent.verticalCenter : key.isDownHashKey ? parent.TopRight : parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    text: pianoView.keyNames[key.keyOctaveIndex] + (key.currentOctave - 1) // Minus one to display the standard A4 middle key
                    color: !key.isHashKey ? "#7B7B7B" : "#E7E7E7"
                    z: 1
                }
            }
        }
    }

    Rectangle {
        y: pianoView.totalHeight - height - (pianoView.targetOctave - pianoView.octaveOffset) * contentView.rowHeight * pianoView.keysPerOctave
        width: contentView.rowHeaderWidth
        height: contentView.rowHeight * keysPerOctave
        color: themeManager.getColorFromChain(pianoView.targetOctave)
        opacity: 0.1
        z: 10
    }

    Item {
        x: contentView.rowHeaderWidth
        width: contentView.rowDataWidth
        height: pianoView.totalHeight

        Repeater {
            model: sequencerView.partition

            delegate: Rectangle {
                readonly property var beatRange: range

                y: ((pianoView.keys - 1 - (key - pianoView.keyOffset)) * contentView.rowHeight)
                x: contentView.xOffset + beatRange.from * contentView.pixelsPerBeatPrecision
                width: (beatRange.to - beatRange.from) * contentView.pixelsPerBeatPrecision
                height: contentView.rowHeight
                color: themeManager.getColorFromChain(key)
                border.color: Qt.darker(color, 1.25)
                border.width: 1
                opacity: 0.9

                DefaultText {
                    visible: parent.width > 30
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    horizontalAlignment: Text.AlignLeft
                    text: keyNames[key % 12] + Math.floor((key / 12) - 1)
                    font.pixelSize: 12
                    color: Qt.darker(parent.border.color, 1.25)
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

        SequencerNotesPlacementArea {
            id: placementArea

            anchors.fill: parent
        }
    }
}
