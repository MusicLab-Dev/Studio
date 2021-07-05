import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import ThemeManager 1.0

import "../Default/"
import "../Common/"

import PluginModel 1.0

Rectangle {
    property alias model: nodeControlsRepeater.model
    property color controlsColor: "black"

    color: themeManager.foregroundColor
    height: controlsColumn.height

    Column {
        id: controlsColumn
        width: parent.width

        Rectangle {
            color: "white"
            width: parent.width
            height: 1
        }

        Flow {
            id: nodeControlsFlow
            width: parent.width
            padding: 20
            spacing: 20

            Repeater {
                id: nodeControlsRepeater

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
                        item.accentColor = color
                    }
                }
            }
        }
    }
}
