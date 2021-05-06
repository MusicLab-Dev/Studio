import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0

import "../Default/"
import "../Common/"

import PluginModel 1.0

Rectangle {
    color: themeManager.foregroundColor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        DefaultSectionWrapper {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.6
            label: "Sampler"

            ListView {
                id: controlsListView
                anchors.fill: parent
                orientation: ListView.Horizontal
                clip: true
                spacing: 2
                model: sequencerView.node ? sequencerView.node.plugin : null
                boundsBehavior: Flickable.StopAtBounds

                delegate: Loader {
                    focus: true

                    source: {
                        switch (controlType) {
                        case PluginModel.Boolean:
                            return "qrc:/Common/PluginControls/BooleanControl.qml"
                        case PluginModel.Integer:
                            return "qrc:/Common/PluginControls/IntegerControl.qml"
                        case PluginModel.Floating:
                            return "qrc:/Common/PluginControls/FloatingControl.qml"
                        case PluginModel.Enum:
                            return "qrc:/Common/PluginControls/EnumControl.qml"
                        default:
                            return ""
                        }
                    }

                    onLoaded: anchors.verticalCenter = parent.verticalCenter
                }
            }
        }

        DefaultSectionWrapper {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.4
            label: "Edition"

            placeholder: RowLayout {
                anchors.fill: parent
                spacing: 10

                ModSelector {
                    id: editModeSelector
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.375
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
                    onItemSelectedChanged: sequencerView.editMode = itemSelected

                    placeholder: Snapper {
                        id: brushSnapper
                        height: editModeSelector.height - editModeSelector.rowContainer.height
                        width: editModeSelector.width
                        visible: sequencerView.editMode === SequencerView.EditMode.Brush
                        currentIndex: 0
                        onActivated: contentView.placementBeatPrecisionBrushStep = currentValue
                    }
                }

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.375
                    Layout.alignment: Qt.AlignHCenter

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 3

                        PartitionComboBox {
                            id: partitionComboBox
                            Layout.preferredHeight: parent.height * 0.4
                            Layout.preferredWidth: parent.width
                            Layout.alignment: Qt.AlignVCenter
                            partitions: sequencerView.node ? sequencerView.node.partitions : null
                            currentIndex: sequencerView.partitionIndex

                            onActivated: {
                                sequencerView.partitionIndex = index
                                sequencerView.partition = sequencerView.node.partitions.getPartition(index)
                            }
                        }

                        Snapper {
                            id: snapper
                            Layout.preferredHeight: parent.height * 0.4
                            Layout.preferredWidth: parent.width
                            currentIndex: 4

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
                }
            }
        }
    }
}
