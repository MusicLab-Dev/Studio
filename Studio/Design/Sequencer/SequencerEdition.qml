import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default/"
import "../Common/"

import ThemeManager 1.0
import PluginModel 1.0

RowLayout {
    spacing: 10

    ModeSelector {
        id: editModeSelector
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.375
        itemUsableTill: 2

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

    Item {
        Layout.preferredHeight: parent.height
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        ColumnLayout {
            anchors.fill: parent
            spacing: 3

            Item {
                Layout.preferredHeight: parent.height * 0.4
                Layout.preferredWidth: parent.width

                RowLayout {
                    spacing: 5
                    anchors.fill: parent

                    PartitionComboBox {
                        id: partitionComboBox
                        Layout.preferredWidth: parent.width * 0.75
                        Layout.preferredHeight: parent.height
                        partitions: sequencerView.node ? sequencerView.node.partitions : null
                        currentIndex: sequencerView.partitionIndex

                        onActivated: {
                            sequencerView.changePartition(index)
                        }
                    }

                    AddButton {
                        id: addBtn
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height

                        onReleased: {
                            sequencerView.player.stop()
                            if (sequencerView.node.partitions.add()) {
                                sequencerView.changePartition(sequencerView.node.partitions.count() - 1)
                            }
                        }
                    }
                }
            }

            Snapper {
                id: snapper
                Layout.preferredHeight: parent.height * 0.4
                Layout.preferredWidth: parent.width
                currentIndex: 2

                onActivated: {
                    contentView.placementBeatPrecisionScale = currentValue
                    contentView.placementBeatPrecisionLastWidth = 0
                }
            }
        }
    }

    ArrowNextPrev {
        Layout.preferredHeight: parent.height
        Layout.preferredWidth: parent.width * 0.25
        Layout.alignment: Qt.AlignHCenter

        next.onPressed: actionsManager.redo()
        next.enabled: true
        prev.onPressed: actionsManager.undo()
        prev.enabled: true
    }
}
