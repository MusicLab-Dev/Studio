import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"
import "../Help"

import Scheduler 1.0

Rectangle {
    property alias player: player
    property alias partitionsPreview: partitionsPreview

    width: parent.width
    height: parent.width
    color: themeManager.foregroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
    }

    HelpArea {
        name: qsTr("Planner Footer")
        description: qsTr("Change the project name on clicked")
        position: HelpHandler.Position.Top | HelpHandler.Position.Left
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
                spacing: 10

                TimerView {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width * 0.25
                    currentPlaybackBeat: player.currentPlaybackBeat
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

    PartitionsPreview {
        id: partitionsPreview
        y: -height

        HelpArea {
            name: qsTr("Partitions preview")
            description: qsTr("Change the project name on clicked")
            position: HelpHandler.Position.Top | HelpHandler.Position.Left
        }
    }
}
