import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Rectangle {
    id: pluginsContentArea
    color: parent.color

    GridView {
        anchors.fill: parent
        cellWidth: 250
        cellHeight: 250


        model: pluginTable

        delegate: PluginsSquareComponent {

            DefaultImageButton {
                anchors.fill: parent
                source: "qrc:/Assets/TestImage1.png"

                onReleased: {
                    pluginsView.acceptAndClose(factoryPath)
                }
            }

            PluginsSquareComponentTitle {
                id: title
                text: factoryName
            }

            Text {
                x: parent.width - width
                y: title.y + title.height
                text: factoryDescription
                color: "#FFFFFF"
                opacity: 0.42
                font.pointSize: 11
                font.weight: Font.Thin

            }
        }
    }
}
