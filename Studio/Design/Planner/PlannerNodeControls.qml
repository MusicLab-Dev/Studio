import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"
import "../Common"
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
            x: nodeHeaderBackground.x
            y: contentView.headerHalfMargin
            width: nodeHeaderBackground.width
            height: nodeControlsFlow.height - contentView.headerMargin

            PluginFactoryImage {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: nodeHeaderMouseArea.containsMouse ? parent.height * 0.6 : parent.height * 0.55
                name: nodeDelegate.node ? nodeDelegate.node.plugin.title : ""
                color: !nodeDelegate.isSelected ? nodeDelegate.color : themeManager.backgroundColor
                playing: nodeHeaderMouseArea.containsMouse

                Behavior on height {
                    NumberAnimation { duration: 100 }
                }
            }

            DefaultImageButton {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: parent.height * 0.55
                source: "qrc:/Assets/SelectorMod.png"
                showBorder: false
                scaleFactor: 1
                colorDefault: themeManager.backgroundColor
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

    Item {
        width: contentView.rowDataWidth
        height: nodeControlsFlow.height

        Rectangle {
            id: nodeControlsData
            anchors.fill: parent
            color: themeManager.contentColor
            opacity: 1
        }

        Flow {
            id: nodeControlsFlow
            anchors.centerIn: parent
            width: parent.width * 0.995
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
                        radius: 6

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
