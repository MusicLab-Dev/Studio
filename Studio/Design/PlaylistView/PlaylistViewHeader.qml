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
            Layout.preferredWidth: parent.width / 3

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.5
                }

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.5

                    ModSelector {
                        id: editModeSelector
                        itemsPath: [
                            "qrc:/Assets/NormalMod.png",
                            "qrc:/Assets/BrushMod.png",
                            // "qrc:/Assets/SelectorMod.png",
                            // "qrc:/Assets/CutMod.png",
                        ]
                        width: parent.width / 2
                        height: parent.height / 2
                        anchors.verticalCenter: parent.verticalCenter

                        onItemSelectedChanged: playlistView.editMode = itemSelected
                    }

                    Snapper {
                        id: brushSnapper
                        visible: playlistView.editMode === PlaylistView.EditMode.Brush
                        x: parent.width / 2
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.height
                        height: parent.height / 2
                        currentIndex: 0

                        onActivated: contentView.placementBeatPrecisionBrushStep = currentValue
                    }
                }
            }
        }
    }
}
