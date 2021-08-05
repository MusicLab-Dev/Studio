import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

import "../Default"

import NodeModel 1.0
import PluginModel 1.0

Item {
    property NodeModel node

    id: debugWnd

    Window {
        id: controlsWindow
        width: 800
        height: 600

        onClosing: {
            controlsWindowSwitch.checked = false
        }

        DefaultSectionWrapper {
            anchors.fill: parent
            label: debugWnd.node ? debugWnd.node.plugin.title : ""

            MouseArea {
                anchors.fill: parent
                onPressedChanged: forceActiveFocus()
            }

            GridLayout {
                id: controlsWindowGrid
                anchors.fill: parent
                clip: true
                columns: 10

                Repeater {
                    id: repeaterTool
                    model: debugWnd.node ? debugWnd.node.plugin : null

                    delegate: Loader {
                        focus: true

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

                        Layout.row: index === 0 ? 0 : (index - 1) / controlsWindowGrid.columns + 1
                        Layout.column: index === 0 ? 0 : (index - 1) % controlsWindowGrid.columns
                    }
                }
            }
        }
    }

    Shortcut {
        property bool checked: false

        id: controlsWindowSwitch
        sequence: "Alt+D"
        onActivated: {
            checked = !checked
            if (checked === true)
                controlsWindow.show()
            else
                controlsWindow.close()
        }
    }
}
