import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    readonly property var keyNames: [
        qsTr("B"), qsTr("A#"), qsTr("A"), qsTr("G#"), qsTr("G"), qsTr("F#"),
        qsTr("F"), qsTr("E"), qsTr("D#"), qsTr("D"), qsTr("C#"), qsTr("C")
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
    property int octaves: 10
    property int octaveOffset: 1
    readonly property int keys: keysPerOctave * octaves
    property real headerFactor: 0.1
    property real rowHeight: 30
    property real keyWidth: parent.width * headerFactor
    readonly property real totalGridHeight: keys * rowHeight

    id: piano
    width: keyWidth
    height: totalGridHeight

    Repeater {

        model: piano.keys

        delegate: Item {
            readonly property int currentOctave: octaveOffset + index / keysPerOctave
            readonly property int keyIndex: index % keysPerOctave
            readonly property bool isHashKey: hashKeyStates[keyIndex]
            readonly property bool isInMiddleOfHashKeys: middleHashKeysStates[keyIndex]
            readonly property bool isUpHashKey: upHashKeyStates[keyIndex]
            readonly property bool isDownHashKey: downHashKeyStates[keyIndex]
            readonly property color keyColor: isHashKey ? "#7B7B7B" : "#E7E7E7"

            id: key
            width: piano.keyWidth
            height: piano.rowHeight
            y: index * piano.rowHeight
            z: isHashKey ? 100 : 1

            Rectangle {
                id: keyBackground
                x: 20
                y: key.isUpHashKey ? -piano.rowHeight / 2 : 0
                z: 1
                width: (key.isHashKey ? piano.keyWidth * 0.75 : piano.keyWidth) - x
                height: piano.rowHeight * (key.isHashKey ? 1 : key.isInMiddleOfHashKeys ? 2 : 1.5)
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
                    text: piano.keyNames[key.keyIndex] + key.currentOctave
                    color: !key.isHashKey ? "#7B7B7B" : "#E7E7E7"
                    z: 1
                }
            }
        }
    }
}