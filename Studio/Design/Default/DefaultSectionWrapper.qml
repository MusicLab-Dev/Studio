import QtQuick 2.4
import QtGraphicalEffects 1.15

Item {
    id: sectionWrapper
    default property alias placeholder: placeholder.data
    property string label: "section"
    property real ratioheight: 0.8
    property real ratioWidth: 0.95

    Rectangle {
        id: container
        anchors.centerIn: parent
        height: parent.height * ratioheight
        width: parent.width * ratioWidth
        color: themeManager.foregroundColor
        radius: 6

        Item {
            id: placeholder
            height: parent.height * 0.75
            width: parent.width * 0.92
            anchors.centerIn: parent
        }

        Item {
            id: labelContainer
            width: text.contentWidth
            height: text.contentHeight
            x: container.x + 10
            y: -height / 2

            Text {
                id: text
                anchors.fill: parent
                color: "white"
                text: qsTr(label.toUpperCase())
                font.weight: Font.DemiBold
            }
        }
    }
}
