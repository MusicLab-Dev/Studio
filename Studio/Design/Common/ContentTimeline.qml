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
            "qrc:/Assets/8on1.png",
            "qrc:/Assets/6on1.png",
            "qrc:/Assets/4on1.png",
            "qrc:/Assets/3on1.png",
            "qrc:/Assets/2on1.png",
            "qrc:/Assets/1on1.png",
            "qrc:/Assets/1on2.png",
            "qrc:/Assets/1on3.png",
            "qrc:/Assets/1on4.png",
            "qrc:/Assets/1on6.png",
            "qrc:/Assets/1on8.png",
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
