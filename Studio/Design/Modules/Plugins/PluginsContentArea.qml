import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: pluginsContentArea
    color: parent.color

    GridView {
        anchors.fill: parent
        cellWidth: 250
        cellHeight: 250


        model: [
            ["Equalizer", PluginsView.Effect | PluginsView.EQ],
            ["Classic piano", PluginsView.Instrument | PluginsView.Piano]
        ]

        delegate: PluginsSquareComponent {

            Image {
                anchors.fill: parent
                source: modelData[0] === "Equalizer" ? "qrc:/Assets/TestImage1.png" : "qrc:/Assets/TestImage2.png"
            }

            PluginsSquareComponentTitle {
                id: title
                text: modelData[0]
            }

            Text {
                x: parent.width - width
                y: title.y + title.height
                text: qsTr("voir plus...")
                color: "#FFFFFF"
                opacity: 0.42
                font.pointSize: 11
                font.weight: Font.Thin

            }
        }
    }
}
