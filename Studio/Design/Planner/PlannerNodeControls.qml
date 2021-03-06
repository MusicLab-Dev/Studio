import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common/PluginControls"

import PluginModel 1.0

Row {
    id: nodeControls

    Item {
        id: nodeControlsHeader
        width: contentView.rowHeaderWidth
        height: nodeControlsFlow.height

        Item {
            id: nodePartitionsBackground
            x: nodeDelegate.isChild ? contentView.childOffset : contentView.headerMargin
            y: contentView.headerHalfMargin
            width: contentView.rowHeaderWidth - x - contentView.headerMargin
            height: nodeControlsFlow.height - contentView.headerMargin

            Rectangle {
                width: parent.width
                height: 1
                color: nodeDelegate.darkColor
            }

            DefaultText {
                x: 10
                width: parent.width * 0.5
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                fontSizeMode: Text.HorizontalFit
                font.pointSize: 20
                color: nodeDelegate.accentColor
                text: "Controls"
                wrapMode: Text.Wrap
            }

            DefaultImageButton {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: Math.min(parent.height / 2, 50)
                source: "qrc:/Assets/SelectorMod.png"
                showBorder: false
                scaleFactor: 1
                colorDefault: nodeDelegate.accentColor
                colorHovered: nodeDelegate.hoveredColor
                colorOnPressed: nodeDelegate.pressedColor

                onReleased: {
                    var alreadySelectedCount = 0
                    var i = 0
                    for (; i < nodeControlsRepeater.count; ++i) {
                        var item = nodeControlsRepeater.itemAt(i)
                        if (item.isSelected)
                            ++alreadySelectedCount
                        else
                            item.isSelected = true
                    }
                    if (alreadySelectedCount === nodeControlsRepeater.count) {
                        for (i = 0; i < nodeControlsRepeater.count; ++i)
                            nodeControlsRepeater.itemAt(i).isSelected = false
                    }
                }
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
            padding: 5
            spacing: 20

            Repeater {
                id: nodeControlsRepeater
                model: nodeDelegate.node ? nodeDelegate.node.plugin : null

                delegate: Column {
                    property bool isSelected: false

                    id: delegateCol
                    spacing: 5

                    onIsSelectedChanged: {
                        if (isSelected)
                            nodeAutomations.pluginProxy.addControl(index)
                        else
                            nodeAutomations.pluginProxy.removeControl(index)
                    }

                    Loader {
                        id: delegateLoader

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

                        onLoaded: {
                            item.accentColor = nodeDelegate.color
                        }
                    }

                    Rectangle {
                        width: delegateLoader.width
                        height: 20
                        color: delegateCol.isSelected ? nodeDelegate.color : themeManager.disabledColor
                        border.color: Qt.lighter(nodeDelegate.color, 1.25)
                        border.width: selectorMouseArea.containsMouse
                        radius: 5

                        MouseArea {
                            id: selectorMouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onPressed: delegateCol.isSelected = !delegateCol.isSelected
                        }

                    }
                }
            }
        }
    }
}