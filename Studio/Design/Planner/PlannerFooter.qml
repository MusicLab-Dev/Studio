import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

import Scheduler 1.0

Rectangle {
    property alias player: player

    width: parent.width
    height: parent.width
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    PlannerPartitionsPreview {
        id: partitionsPreview
        y: -height
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 3
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 3

            RowLayout {
                anchors.fill: parent
                spacing: 20

                TimerView {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width * 0.25
                }

                Player {
                    id: player
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width * 0.25
                    targetPlaybackMode: Scheduler.Production
                }

                Bpm {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width * 0.25
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 3

            DefaultImageButton {
                visible: contentView.lastSelectedNode && partitionsPreview.hide
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height * 0.5
                showBorder: false
                scaleFactor: 1
                source: "qrc:/Assets/Note.png"

                onReleased: partitionsPreview.hide = false
            }
        }
    }
}