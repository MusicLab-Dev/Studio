import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Project 1.0

import "../Common"
import "../Default"

Rectangle {
    color: themeManager.foregroundColor

    // ComboBox {
    //     id: playlistBeatScaleList
    //     x: parent.width * 0.1
    //     y: parent.height * 0.1
    //     model: ["Free", "1:128", "1:64", "1:32", "1:16", "1:8", "1:4", "1:2", "1:1", "2:1", "4:1", "8:1", "16:1", "32:1", "64:1", "128:1"]
    //     currentIndex: contentView.contentView.placementBeatPrecisionScale !== 0 ? Math.log2(contentView.contentView.placementBeatPrecisionScale) + 1 : 0

    //     onActivated: {
    //         if (!index)
    //             contentView.contentView.placementBeatPrecisionScale = 0
    //         else
    //             contentView.contentView.placementBeatPrecisionScale = Math.pow(2, index - 1)
    //         contentView.contentView.placementBeatPrecisionLastWidth = 0
    //     }
    // }
}
