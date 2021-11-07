import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"
import "../Help"

import Scheduler 1.0

Rectangle {
    property alias player: player

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
                    currentPlaybackBeat: player.playerBase.currentPlaybackBeat
                }

                PlayerRef {
                    id: player
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.preferredWidth: parent.width * 0.25
                    playerBase: modulesView.productionPlayerBase
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
                visible: contentView.selectedNode && contentView.partitionsPreview.hide
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height * 0.5
                showBorder: false
                scaleFactor: 1
                source: "qrc:/Assets/Note.png"

                onReleased: contentView.partitionsPreview.hide = false
            }
        }
    }
}
