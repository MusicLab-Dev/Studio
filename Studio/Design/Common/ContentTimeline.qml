import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../Default"

Row {
    property alias headerWidth: itemDropModSelector.width
    property variant metricValues: [
        0, 16, 128 / 6, 32, 128 / 3, 64, 128, 256, 384, 512, 768, 1024
    ]

    ModSelector {
        id: itemDropModSelector
        height: parent.height
        smallVersion: true
        itemSelected: 0
        itemsPath: [
            "qrc:/Assets/Free.png",
            "1/8",
            "1/6",
            "1/4",
            "1/3",
            "1/2",
            "1/1",
            "2/1",
            "3/1",
            "4/1",
            "6/1",
            "8/1",
        ]
        onItemSelectedChanged: {
            contentView.placementBeatPrecisionScale = metricValues[itemSelected]
            contentView.placementBeatPrecisionLastWidth = 0
        }
    }

    Rectangle {
        id: timeline
        width: parent.width - headerWidth
        color: themeManager.disabledColor
    }
}
