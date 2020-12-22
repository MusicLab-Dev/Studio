import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Rectangle {
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
    property real rowHeight: 50
    property real keyWidth: width * headerFactor
    readonly property real totalGridHeight: grid.keys * rowHeight 

    id: grid
    color: "#4A8693"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        contentHeight: totalGridHeight

        Repeater {
            model: 12

            delegate: Rectangle {
                height: totalGridHeight
                width: 2
                color: "black"
                x: index * 200 + (keyWidth + 200)
            }
        }

        Repeater {
            model: grid.keys

            delegate: Item {
                readonly property int currentOctave: octaveOffset + index / keysPerOctave
                readonly property int keyIndex: index % keysPerOctave
                readonly property bool isHashKey: hashKeyStates[keyIndex]
                readonly property bool isInMiddleOfHashKeys: middleHashKeysStates[keyIndex]
                readonly property bool isUpHashKey: upHashKeyStates[keyIndex]
                readonly property bool isDownHashKey: downHashKeyStates[keyIndex]
                readonly property color keyColor: isHashKey ? "#7B7B7B" : "#E7E7E7"

                width: grid.width
                height: grid.rowHeight
                y: index * grid.rowHeight
                z: isHashKey ? 100 : 1

                Rectangle {
                    id: key
                    y: isUpHashKey ? -grid.rowHeight / 2 : 0
                    z: 1
                    width: isHashKey ? grid.keyWidth * 0.75 : grid.keyWidth
                    height: grid.rowHeight * (isHashKey ? 1 : isInMiddleOfHashKeys ? 2 : 1.5)
                    color: keyColor
                    border.color: isHashKey ? color : "#7B7B7B"
                    border.width: 1

                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            key.color = Qt.darker(key.color, 1.2)
                        }
                        onReleased: {
                            key.color = keyColor
                        }
                    }

                    Text {
                        anchors.verticalCenter: isInMiddleOfHashKeys ? parent.verticalCenter : isDownHashKey ? parent.TopRight : parent.verticalCenter
                        anchors.right: parent.right
                        text: grid.keyNames[keyIndex] + currentOctave
                        color: !isHashKey ? "#7B7B7B" : "#E7E7E7"
                        z: 1
                    }
                }

                Rectangle {
                    x: keyWidth
                    y: grid.rowHeight
                    height: 1
                    width: grid.width
                    color: "black"
                }
            }
        }
    }
}
