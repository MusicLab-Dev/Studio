import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Project 1.0

import "../Common"
import "../Default"


Rectangle {
    color: themeManager.foregroundColor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.6

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
                    onItemSelectedChanged: playlistView.editMode = itemSelected

                    placeholder: Snapper {
                        id: brushSnapper
                        height: editModeSelector.height - editModeSelector.rowContainer.height
                        width: editModeSelector.width
                        visible: playlistView.editMode === PlaylistView.EditMode.Brush
                        currentIndex: 0
                        onActivated: contentView.placementBeatPrecisionBrushStep = currentValue
                        rectBackground.border.width: 0
                        rectBackground.color: "transparent"
                    }
                }

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.375
                    Layout.alignment: Qt.AlignHCenter

                    Snapper {
                        id: snapper
                        height: parent.height * 0.4
                        width: parent.width
                        currentIndex: 4
                        anchors.verticalCenter: parent.verticalCenter

                        onActivated: {
                            contentView.placementBeatPrecisionScale = currentValue
                            contentView.placementBeatPrecisionLastWidth = 0
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
