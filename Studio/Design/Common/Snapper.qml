import QtQuick 2.0

Item {
    readonly property variant metricValues: [
        0, 16, 128 / 6, 32, 128 / 3, 64, 128, 256, 384, 512, 768, 1024
    ]

    ModSelector {
        id: itemDropModSelector
        height: parent.height
        width: parent.width
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
}
