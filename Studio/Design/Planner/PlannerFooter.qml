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
    color: themeManager.backgroundColor

    MouseArea {
        anchors.fill: parent
        onPressedChanged: forceActiveFocus()
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

            HelpArea {
                name: qsTr("Player Area")
                description: qsTr("Description")
                position: HelpHandler.Position.Left | HelpHandler.Position.Top
                externalDisplay: true
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
            name: qsTr("Partitions")
            description: qsTr("Description")
            position: HelpHandler.Position.Top
            externalDisplay: true
            visible: partitionsPreview.visible
        }
    }
}