import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

Rectangle {
    id: pluginsContentArea
    color: parent.color

    GridView {
        anchors.fill: parent
        cellWidth: Math.min(160, parent.width / 6) === 160 ? 250 : 200
        cellHeight: cellWidth

        model: pluginTable

        delegate: PluginsSquareComponent {
            property bool pluginsSquareComponentHovered: false

            id: delegate

            Image {
                width: parent.width / 1.5
                height: width
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2
                source: factoryName ? "qrc:/Assets/Plugins/" + factoryName + ".png" : "qrc:/Assets/Plugins/Default.png"
            }

            PluginsSquareComponentTitle {
                id: title
                text: factoryName
            }

            PluginsSquareComponentDescription {
                id: description
                text: factoryDescription

                ToolTip {
                    id: toolTip
                    text: factoryDescription
                    visible: false
                }
            }

            MouseArea {
                width: parent.width
                height: parent.height + title.height + description.height
                hoverEnabled: true

                onEntered: {
                    pluginsSquareComponentHovered = true
                    toolTip.visible = description.truncated ? true : false
                }

                onExited: {
                    pluginsSquareComponentHovered = false
                    toolTip.visible = false
                }

                onReleased: {
                    pluginsView.acceptAndClose(factoryPath)
                }
            }
        }
    }
}
