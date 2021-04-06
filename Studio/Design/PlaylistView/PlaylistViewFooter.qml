import QtQuick 2.15
import QtQuick.Layouts 1.15

import "../Common"
import "../Default"

import Scheduler 1.0

Rectangle {
    width: parent.width
    height: parent.width
    color: themeManager.foregroundColor

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            Player {
                anchors.centerIn: parent
                height: parent.height
                width: 200
                targetPlaybackMode: Scheduler.Production
            }
        }

        Item {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.333

            Bpm {
                anchors.centerIn: parent
                height: parent.height / 2
                width: parent.width / 3
            }
        }
    }
}

