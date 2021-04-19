import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

import PluginTableModel 1.0

GridView {
    property alias pluginTableProxy: pluginTableProxy

    id: pluginsGrid
    cellWidth: pluginsContentArea.width / 6
    cellHeight: cellWidth
    clip: true

    model: PluginTableModelProxy {
        id: pluginTableProxy
        sourceModel: pluginTable
        tagsFilter: pluginsView.currentFilter
        nameFilter: pluginsForeground.currentSearchText
    }

    ScrollBar.vertical: DefaultScrollBar {
        id: scrollBar
        color: "#31A8FF"
        opacity: 0.3
        visible: parent.contentHeight > parent.height
    }

    delegate: Item {
        property bool pluginsSquareComponentHovered: false

        id: componentDelegate
        width: pluginsGrid.cellWidth
        height: pluginsGrid.cellHeight

        PluginsSquareComponent {
            anchors.fill: parent
            anchors.margins: 5

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
                width: parent.width
                height: parent.height / 2
                x: parent.width / 2 - width / 2
                y: title.y * 1.2

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
