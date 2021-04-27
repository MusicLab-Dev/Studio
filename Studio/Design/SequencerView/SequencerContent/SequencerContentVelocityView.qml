import QtQuick 2.15
import QtQuick.Controls 2.15

import AudioAPI 1.0

Rectangle {
    color: "grey"

    Row {
        anchors.fill: parent

        Rectangle {
            color: "darkgrey"
            width: contentView.rowHeaderWidth
            height: parent.height
        }

        Rectangle {
            width: parent.width - contentView.rowHeaderWidth
            height: contentView.rowDataWidth

            Repeater {
                model: sequencerView.partition

                delegate: Rectangle {
                    readonly property var beatRange: range

                    y: height * (velocity / AudioAPI.velocityMax) - height / 2
                    x: contentView.xOffset + beatRange.from * contentView.pixelsPerBeatPrecision
                    width: (beatRange.to - beatRange.from) * contentView.pixelsPerBeatPrecision
                    height: 4
                    color: themeManager.getColorFromChain(key)
                }
            }
        }
    }
}