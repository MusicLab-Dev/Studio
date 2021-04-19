import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Project 1.0

import "../Common"
import "../Default"

Rectangle {

    width: parent.width
    height: parent.width
    color: themeManager.foregroundColor

    /** Debug */
    Row {
        anchors.fill: parent
        Button {
            anchors.verticalCenter: parent.verticalCenter
            width: 50
            height: 40
            onPressed: app.project.save()
            text: "save"

        }
        Button {
            anchors.verticalCenter: parent.verticalCenter
            width: 50
            height: 40
            onPressed: app.project.load()
            text: "load"

        }
    }
    /** ---- */

    ComboBox {
        id: playlistBeatScaleList
        x: parent.width * 0.1
        y: parent.height * 0.1
        model: ["Free", "1:128", "1:64", "1:32", "1:16", "1:8", "1:4", "1:2", "1:1", "2:1", "4:1", "8:1", "16:1", "32:1", "64:1", "128:1"]
        currentIndex: playlistViewContent.contentView.placementBeatPrecisionScale !== 0 ? Math.log2(playlistViewContent.contentView.placementBeatPrecisionScale) + 1 : 0

        onActivated: {
            if (!index)
                playlistViewContent.contentView.placementBeatPrecisionScale = 0
            else
                playlistViewContent.contentView.placementBeatPrecisionScale = Math.pow(2, index - 1)
            playlistViewContent.contentView.placementBeatPrecisionLastWidth = 0
        }
    }
}
