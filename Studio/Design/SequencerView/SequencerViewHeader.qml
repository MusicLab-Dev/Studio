import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0
import "../Default/"
import "../Common/"

Rectangle {
    color: themeManager.foregroundColor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.5

                    DefaultComboBox {
                        width: parent.width / 2
                        height: parent.height / 2
                        anchors.centerIn: parent
                        model: [
                            "Sequence1",
                            "Sequence2",
                            "Sequence3"
                        ]
                    }
                }

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.5

                    ModSelector {
                        itemsPath: [
                            "qrc:/Assets/NormalMod.png",
                            "qrc:/Assets/BrushMod.png",
                            "qrc:/Assets/SelectorMod.png",
                            "qrc:/Assets/CutMod.png",
                        ]
                        width: parent.width / 2
                        height: parent.height / 2
                        anchors.centerIn: parent

                        onItemSelectedChanged: {

                        }
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.2

            ComboBox {
                id: sequencerBeatScaleList
                model: ["Free", "1:128", "1:64", "1:32", "1:16", "1:8", "1:4", "1:2", "1:1", "2:1", "4:1", "8:1", "16:1", "32:1", "64:1", "128:1"]
                currentIndex: sequencerViewContent.contentView.placementBeatPrecisionScale !== 0 ? Math.log2(sequencerViewContent.contentView.placementBeatPrecisionScale) + 1 : 0

                onActivated: {
                    if (!index)
                        sequencerViewContent.contentView.placementBeatPrecisionScale = 0
                    else
                        sequencerViewContent.contentView.placementBeatPrecisionScale = Math.pow(2, index - 1)
                    console.info(sequencerViewContent.contentView.placementBeatPrecisionScale)
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.133

            ArrowNextPrev {
                anchors.fill: parent
            }
        }
    }
}
