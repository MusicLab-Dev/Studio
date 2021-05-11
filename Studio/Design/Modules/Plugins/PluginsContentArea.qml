import QtQuick 2.15
import QtQuick.Controls 2.15

import "../../Default"

import PluginTableModel 1.0

GridView {
    property alias pluginTableProxy: pluginTableProxy

    id: pluginsGrid
    cellWidth: 150
    cellHeight: cellWidth * 1.6
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
        //visible: parent.contentHeight > parent.height
        visible: false
    }

    delegate: Item {
        property bool pluginsSquareComponentHovered: false

        id: componentDelegate
        width: pluginsGrid.cellWidth
        height: pluginsGrid.cellHeight

        PluginsSquareComponent {
            id: pluginSquareComponent
            width: pluginsGrid.cellWidth - x * 2
            height: pluginsGrid.cellHeight / 1.6
            x: 7
            y: 10

            Image {
                width: parent.width / 1.5
                height: width
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2
                source: factoryName ? "qrc:/Assets/Plugins/" + factoryName + ".png" : "qrc:/Assets/Plugins/Default.png"
            }
        }

        PluginsSquareComponentTitle {
            id: title
            text: factoryName
            anchors.top: pluginSquareComponent.bottom
        }

        PluginsSquareComponentDescription {
            id: description
            text: factoryDescription
            anchors.top: title.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            ToolTip {
                id: toolTip
                text: factoryDescription
                visible: pluginsSquareComponentArea.containsMouse && description.truncated
            }
        }

        MouseArea {
            id: pluginsSquareComponentArea
            anchors.fill: parent
            hoverEnabled: true

            onReleased: {
                pluginsView.acceptAndClose(factoryPath)
            }
        }
    }
}
