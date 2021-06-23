import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

import PluginModel 1.0

Row {
    id: nodeControls

    Item {
        id: nodeControlsHeader
        width: contentView.rowHeaderWidth
        height: nodeControlsFlow.height

        Item {
            id: nodePartitionsBackground
            x: nodeDelegate.isChild ? contentView.rowHeaderWidth * 0.25 : 10
            y: 5
            width: contentView.rowHeaderWidth - x - 10
            height: nodeControlsFlow.height - 10

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.darker(nodeDelegate.color, 1.25)
            }

            DefaultText {
                anchors.centerIn: parent
                text: "Controls"
            }
        }
    }

    Rectangle {
        id: nodeControlsData
        width: contentView.rowDataWidth
        height: nodeControlsFlow.height
        color: themeManager.foregroundColor
        opacity: 0.75

        Flow {
            id: nodeControlsFlow
            width: contentView.rowDataWidth
            padding: 2
            spacing: 2

            Repeater {
                id: nodeControlsRepeater
                model: nodeDelegate.node ? nodeDelegate.node.plugin : null

                delegate: Loader {
                    source: {
                        switch (controlType) {
                        case PluginModel.Boolean:
                            return "qrc:/Common/PluginControls/BooleanControl.qml"
                        case PluginModel.Integer:
                            return "qrc:/Common/PluginControls/IntegerControl.qml"
                        case PluginModel.Floating:
                            return "qrc:/Common/PluginControls/FloatingControl.qml"
                        case PluginModel.Enum:
                            return "qrc:/Common/PluginControls/EnumControl.qml"
                        default:
                            return ""
                        }
                    }
                }
            }
        }
    }
}