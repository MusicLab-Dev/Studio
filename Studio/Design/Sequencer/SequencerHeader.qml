import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.0

import "../Common"
import "../Default"

import Scheduler 1.0
import NodeModel 1.0
import ThemeManager 1.0
import CursorManager 1.0

Rectangle {
    property alias player: playerArea.player
    property alias tweaker: tweaker

    width: parent.width
    height: parent.height
    color: themeManager.backgroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    DefaultImageButton {
        id: undoButton
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7
        source: "qrc:/Assets/Previous.png"
        foregroundColor: themeManager.contentColor
        colorHovered: sequencerView.node ? sequencerView.node.color : themeManager.accentColor

        onClicked: actionsManager.undo()

        DefaultToolTip {
            text: "Undo"
            visible: parent.hovered
        }
    }

    DefaultImageButton {
        id: redoButton
        anchors.left: undoButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7
        source: "qrc:/Assets/Next.png"
        foregroundColor: themeManager.contentColor
        colorHovered: sequencerView.node ? sequencerView.node.color : themeManager.accentColor

        onClicked: actionsManager.redo()

        DefaultToolTip {
            text: "Redo"
            visible: parent.hovered
        }
    }

    ModeSelector {
        id: editModeSelector
        anchors.left: redoButton.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        itemUsableTill: 2
        width: parent.width * 0.12
        height: parent.height * 0.7
        color: sequencerView.node ? sequencerView.node.color : themeManager.accentColor

        itemsPaths: [
            "qrc:/Assets/NormalMod.png",
            "qrc:/Assets/BrushMod.png",
            "qrc:/Assets/SelectorMod.png",
            "qrc:/Assets/CutMod.png",
        ]

        itemsNames: [
            "Standard",
            "Brush",
            "Selector",
            "CutMod",
        ]

        placeholder: Snapper {
            id: brushSnapper
            height: editModeSelector.height - editModeSelector.rowContainer.height
            width: editModeSelector.width
            visible: contentView.editMode === ContentView.EditMode.Brush
            currentIndex: 0
            rectBackground.border.width: 0
            rectBackground.color: "transparent"

            onActivated: contentView.placementBeatPrecisionBrushStep = currentValue
        }

        onItemSelectedChanged: contentView.editMode = itemSelected
    }

    SoundMeter {
        id: soundMeter
        anchors.left: editModeSelector.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height * 0.7
        width: height / 3
        targetNode: sequencerView.node
        enabled: sequencerView.visible
        backgroundColor: themeManager.contentColor

        mouseArea.onHoveredChanged: {
            if (mouseArea.containsMouse)
                cursorManager.set(CursorManager.Type.Clickable)
            else
                cursorManager.set(CursorManager.Type.Normal)
        }
    }

    SequencerSettingsPartition {
        id: partitionComboBox
        anchors.left: soundMeter.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.1
        height: parent.height * 0.7
        spacing: 5
    }

    DefaultImageButton {
        id: plannerButton
        anchors.left: partitionComboBox.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: height
        height: parent.height * 0.7
        source: "qrc:/Assets/Chrono.png"
        foregroundColor: themeManager.contentColor
        colorHovered: sequencerView.node ? sequencerView.node.color : themeManager.accentColor

        onClicked: modulesView.addNewPlanner(sequencerView.node)

        DefaultToolTip {
            text: "Move to planner"
            visible: parent.hovered
        }
    }

    ClipboardIndicator {
        anchors.left: partitionComboBox.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height * 0.7
        width: height
    }

    PlayerArea {
        id: playerArea
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: parent.width * 0.3
        height: parent.height * 0.7
        anchors.verticalCenter: parent.verticalCenter
        player.targetPlaybackMode: Scheduler.Partition
        player.isPartitionPlayer: true
        player.targetNode: sequencerView.node
        player.targetPartitionIndex: sequencerView.partitionIndex
    }

    Item {
        visible: false
        anchors.right: playerArea.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.1
        height: parent.height * 0.6

        ModeSelector {
            id: tweaker
            itemsPaths: [
                "qrc:/Assets/EditMod.png",
                "qrc:/Assets/VelocityMod.png",
                "qrc:/Assets/TunningMod.png",
                "qrc:/Assets/AfterTouchMod.png",
            ]
            itemsNames: [
                "Standard",
                "Velocity",
                "Tunning",
                "Aftertouch",
            ]
            anchors.fill: parent
            itemUsableTill: 0
            onItemSelectedChanged: {
                sequencerView.tweakMode = itemSelected
            }
        }
    }
}

