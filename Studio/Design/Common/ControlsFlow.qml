import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0

import NodeModel 1.0

import "../Default/"
import "../Common/"

import PluginModel 1.0

Rectangle {
    property NodeModel node

    color: Qt.darker(themeManager.foregroundColor, 1.1)
    height: controlsColumn.height

    Column {
        id: controlsColumn
        width: parent.width

        Rectangle {
            color: "black"
            width: parent.width
            height: 1
        }

        Item {

            height: nodeControlsFlow.height
            width: parent.width

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width * 0.07

                    DefaultText {
                        anchors.fill: parent
                        text: node ? node.plugin.title : ""
                        color: node ? node.color : "white"
                        font.pixelSize: 30
                        fontSizeMode: Text.Fit
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Flow {
                        id: nodeControlsFlow
                        width: parent.width
                        padding: 15
                        spacing: 20

                        Repeater {
                            id: nodeControlsRepeater
                            model: node ? node.plugin : null

                            delegate: Loader {
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
                                    item.accentColor = node.color
                                }
                            }
                        }
                    }
                }

            }

        }
    }
}
