import QtQuick 2.15

import "../Default"

import AudioAPI 1.0
import Scheduler 1.0
import PartitionPreview 1.0

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
        anchors.fill: parent
        color: themeManager.foregroundColor
        border.color: previewDelegate.isSelected ? partitionsPreview.nodeColor : partitionsPreview.nodeAccentColor
        border.width: previewDelegate.isSelected || previewDelegate.containsMouse ? 1 : 0
        radius: 3
    }

    PartitionPreview {
        id: previewArea
        y: 2
        x: -(previewDelegate.playbackBeatPrecision * contentView.pixelsPerBeatPrecision)
        width: previewDelegate.partition ? previewDelegate.partition.latestNote * contentView.pixelsPerBeatPrecision : 0
        height: parent.height - 4
        target: previewDelegate.partition
        offset: 0
        range: AudioAPI.beatRange(0, previewDelegate.partition ? previewDelegate.partition.latestNote : 0)
    }

    DefaultText {
        id: headerName
        visible: !previewDelegate.playing
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10 + playbackButton.width
        anchors.right: playbackButton.left
        fontSizeMode: Text.Fit
        font.pointSize: 12
        opacity: 0.8
        wrapMode: Text.Wrap
        text: previewDelegate.partition ? previewDelegate.partition.name : qsTr("ERROR")
        color: previewDelegate.containsPress ? partitionsPreview.nodePressedColor : partitionsPreview.nodeColor
    }

    DefaultImageButton {
        id: playbackButton
        visible: previewDelegate.isSelected || previewDelegate.containsMouse
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: height
        height: parent.height
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
