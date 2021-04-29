import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import "../Default"

Item {
    readonly property variant metrics: [
        "Free",
        "1/8",
        "1/4",
        "1/2",
        "1/1",
        "2/1",
        "3/1",
        "4/1",
        "6/1",
        "8/1",
    ]
    readonly property variant metricValues: [
        0, 16, 32, 64, AudioAPI.beatPrecision, 256, 384, 512, 768, 1024
    ]

    id: snapper

    ComboBox {
        height: parent.height
        width: parent.width
        model: metrics
        currentIndex: 4

        onActivated: {
            contentView.placementBeatPrecisionScale = metricValues[index]
            contentView.placementBeatPrecisionLastWidth = 0
        }

        delegate: ItemDelegate {
            contentItem: Text {
                anchors.centerIn: parent
                text: metrics[index]
                color: "#000000"
            }
        }
    }
}
