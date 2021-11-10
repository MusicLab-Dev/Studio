import QtQuick 2.15

import "../Default"

import AudioAPI 1.0
import Scheduler 1.0
import PartitionPreview 1.0
import CursorManager 1.0

MouseArea {
    readonly property var partition: partitionInstance.instance
    readonly property int partitionIndex: index
    property bool playing: false
    property int playbackBeatPrecision: 0
    readonly property bool isSelected: partition == contentView.selectedPartition

    id: previewDelegate
    clip: true
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    // onClicked doesn't work because of onDoubleClicked event, so we use onReleased with containsMouse check
    onReleased: {
        if (!containsMouse)
            return
        else if (mouse.button === Qt.RightButton) {
            partitionMenu.openMenu(previewDelegate, nodeDelegate.node, partition, partitionIndex)
            partitionMenu.x = mouse.x
            partitionMenu.y = mouse.y
        } else {
            contentView.selectPartition(nodeDelegate.node, partitionIndex)
        }
    }

    onPressAndHold: {
        partitionMenu.openMenu(previewDelegate, nodeDelegate.node, partition, partitionIndex)
        partitionMenu.x = mouse.x
        partitionMenu.y = mouse.y
    }

    onDoubleClicked: {
        modulesView.addSequencerWithExistingPartition(partitionsPreview.nodeDelegate.node, previewDelegate.partitionIndex)
    }

    onHoveredChanged: {
        if (containsMouse)
            cursorManager.set(CursorManager.Type.Clickable)
        else
            cursorManager.set(CursorManager.Type.Normal)
    }

    Timer {
        id: playbackTimer
        interval: 16
        repeat: true
        triggeredOnStart: true
        running: false

        onTriggered: {
            var elapsed = app.scheduler.getAudioElapsedBeat()
            previewDelegate.playbackBeatPrecision = elapsed % previewArea.range.to
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: themeManager.contentColor
        radius: 3
    }

    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height * 0.2
        color: partitionsPreview.nodeColor
        opacity: previewDelegate.isSelected ? 1 : 0.3
        radius: 3
    }

    DefaultText {
        id: headerName
        anchors.fill: header
        font.pointSize: 8
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        padding: 5
        text: previewDelegate.partition ? previewDelegate.partition.name : qsTr("ERROR")
        color: themeManager.panelColor
    }

    PartitionPreview {
        id: previewArea
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        x: -(previewDelegate.playbackBeatPrecision * contentView.pixelsPerBeatPrecision)
        width: previewDelegate.partition ? previewDelegate.partition.latestNote * contentView.pixelsPerBeatPrecision : 0
        target: previewDelegate.partition
        offset: 0
        range: AudioAPI.beatRange(0, previewDelegate.partition ? previewDelegate.partition.latestNote : 0)
    }

    DefaultImageButton {
        id: playbackButton
        visible: previewDelegate.isSelected || previewDelegate.containsMouse
        anchors.verticalCenter: previewArea.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: height
        height: previewArea.height
        source: "qrc:/Assets/Play.png"
        showBorder: false
        scaleFactor: 0.5
        colorDefault: partitionsPreview.nodeColor
        colorHovered: partitionsPreview.nodeHoveredColor
        colorOnPressed: partitionsPreview.nodePressedColor

        onPressedChanged: {
            if (pressed) {
                previewDelegate.playing = true
                app.scheduler.playPartition(
                    Scheduler.PlaybackMode.Partition,
                    partitionsPreview.node,
                    previewDelegate.partitionIndex,
                    0,
                    previewArea.range
                )
                playbackTimer.start()
            } else {
                app.scheduler.stop()
                playbackTimer.stop()
                previewDelegate.playbackBeatPrecision = 0
                previewDelegate.playing = false
            }
        }
    }

}
