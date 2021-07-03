import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../Default"
import "../Common"

Rectangle {
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

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

                EditionModeSelector {
                    id: editModeSelector
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.375
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